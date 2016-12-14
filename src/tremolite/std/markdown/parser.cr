class Markdown::Parser
  def initialize(text : String, @renderer : Renderer)
    @lines = text.lines.map &.chomp
    @line = 0

    @references = Hash(String, Tuple(String, String)).new
  end

  def parse
    process_for_references

    while @line < @lines.size
      process_paragraph
    end
  end

  def process_for_references
    # analyze and add
    while @line < @lines.size
      if add_reference_line(@lines[@line])
        # if current line was reference definition remove them
        @lines.delete_at(@line)
      else
        @line += 1
      end
    end

    @line = 0

    # replace existing referenced links to regular ones
    # it is easier to integrate with current processor
    while @line < @lines.size
      # two params reference
      result = @lines[@line].scan(/\[([^\]]+)\]\[([^\]]+)\]/)
      unless result.empty?
        match = result.first
        key = match[2]
        if @references[key]?
          text = match[1].to_s
          url = @references[key][0]
          escaped_url = url # .gsub(/\)/, "%29").gsub(/\(/, "%28")
          origin = match[0]

          @lines[@line] = @lines[@line].gsub(origin, "[#{text}](#{escaped_url})")

          next
        end
      end

      # one param reference
      result = @lines[@line].scan(/\[([^\]]+)\][^\[\(]/)
      unless result.empty?
        match = result.first
        key = match[1]
        if @references[key]?
          text = @references[key][1]
          url = @references[key][0]
          escaped_url = url # .gsub(/\)/, "%29").gsub(/\(/, "%28")
          origin = match[0][0..-2]

          @lines[@line] = @lines[@line].gsub(origin, "[#{text}](#{escaped_url})")
        end
      end

      @line += 1
    end

    @line = 0
  end

  def add_reference_line(line)
    regexp = /^\[([^\n\]]+)\]:[ \t]*(\S+)\s*(\S*)?$/
    res = line.scan(regexp)
    if res.size > 0
      match = res[0]
      if match.as?(Regex::MatchData) && false == match[1].blank? && false == match[2].blank?
        @references[match[1].to_s] = {match[2].to_s, match[3].to_s}
        return true
      end
    end
    return false
  end

  def process_line(line)
    bytesize = line.bytesize
    str = line.to_unsafe
    pos = 0

    while pos < bytesize && str[pos].unsafe_chr.ascii_whitespace?
      pos += 1
    end

    cursor = pos
    one_star = false
    two_stars = false
    one_underscore = false
    two_underscores = false
    one_backtick = false
    in_link = false
    last_is_space = true

    while pos < bytesize
      case str[pos].unsafe_chr
      when '*'
        if pos + 1 < bytesize && str[pos + 1].unsafe_chr == '*'
          if two_stars || has_closing?('*', 2, str, (pos + 2), bytesize)
            @renderer.text line.byte_slice(cursor, pos - cursor)
            pos += 1
            cursor = pos + 1
            if two_stars
              @renderer.end_bold
            else
              @renderer.begin_bold
            end
            two_stars = !two_stars
          end
        elsif one_star || has_closing?('*', 1, str, (pos + 1), bytesize)
          @renderer.text line.byte_slice(cursor, pos - cursor)
          cursor = pos + 1
          if one_star
            @renderer.end_italic
          else
            @renderer.begin_italic
          end
          one_star = !one_star
        end
      when '_'
        if pos + 1 < bytesize && str[pos + 1].unsafe_chr == '_'
          if two_underscores || (last_is_space && has_closing?('_', 2, str, (pos + 2), bytesize))
            @renderer.text line.byte_slice(cursor, pos - cursor)
            pos += 1
            cursor = pos + 1
            if two_underscores
              @renderer.end_bold
            else
              @renderer.begin_bold
            end
            two_underscores = !two_underscores
          end
        elsif one_underscore || (last_is_space && has_closing?('_', 1, str, (pos + 1), bytesize))
          @renderer.text line.byte_slice(cursor, pos - cursor)
          cursor = pos + 1
          if one_underscore
            @renderer.end_italic
          else
            @renderer.begin_italic
          end
          one_underscore = !one_underscore
        end
      when '`'
        if one_backtick || has_closing?('`', 1, str, (pos + 1), bytesize)
          @renderer.text line.byte_slice(cursor, pos - cursor)
          cursor = pos + 1
          if one_backtick
            @renderer.end_inline_code
          else
            @renderer.begin_inline_code
          end
          one_backtick = !one_backtick
        end
      when '!'
        if pos + 1 < bytesize && str[pos + 1] === '['
          link = check_link str, (pos + 2), bytesize
          if link
            @renderer.text line.byte_slice(cursor, pos - cursor)

            bracket_idx = (str + pos + 2).to_slice(bytesize - pos - 2).index(']'.ord).not_nil!
            alt = line.byte_slice(pos + 2, bracket_idx)

            @renderer.image link, alt

            paren_idx = (str + pos + 2 + bracket_idx + 1).to_slice(bytesize - pos - 2 - bracket_idx - 1).index(')'.ord).not_nil!
            pos += 2 + bracket_idx + 1 + paren_idx
            cursor = pos + 1
          end
        end
      when '['
        unless in_link
          link = check_link str, (pos + 1), bytesize
          if link
            @renderer.text line.byte_slice(cursor, pos - cursor)
            cursor = pos + 1
            @renderer.begin_link link
            in_link = true
          end
        end
      when ']'
        if in_link
          @renderer.text line.byte_slice(cursor, pos - cursor)
          @renderer.end_link

          # in case of url with parenthesis
          paren_count = 0
          while pos < bytesize
            case str[pos].unsafe_chr
            when '('
              paren_count += 1
            when ')'
              paren_count -= 1
              if paren_count == 0
                break
              end
            end
            pos += 1
          end

          cursor = pos + 1
          in_link = false
        end
      end
      last_is_space = pos < bytesize && str[pos].unsafe_chr.ascii_whitespace?
      pos += 1
    end

    @renderer.text line.byte_slice(cursor, pos - cursor)
  end

  def check_link(str, pos, bytesize)
    # We need to count nested brackets to do it right
    bracket_count = 1
    while pos < bytesize
      case str[pos].unsafe_chr
      when '['
        bracket_count += 1
      when ']'
        bracket_count -= 1
        if bracket_count == 0
          break
        end
      end
      pos += 1
    end

    return nil unless bracket_count == 0
    bracket_idx = pos

    return nil unless str[bracket_idx + 1] === '('

    pos += 1
    paren_count = 0
    paren_start_idx = -1
    paren_end_idx = -1
    while pos < bytesize
      case str[pos].unsafe_chr
      when '('
        paren_start_idx = pos if paren_start_idx < 0
        paren_count += 1
      when ')'
        paren_count -= 1
        if paren_count == 0
          paren_end_idx = pos
          s = String.new(Slice.new(str + paren_start_idx + 1, paren_end_idx - paren_start_idx - 1))
          return s
          break
        end
      end
      pos += 1
    end
  end
end
