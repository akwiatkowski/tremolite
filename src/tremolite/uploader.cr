require "logger"

# NOTE I'll finish it later probably. I've found out `lftp`
# http://www.serveridol.com/2010/02/18/how-do-i-syncronize-the-ftp-files-incremental-ftp-backup/

class Tremolite::Uploader
  def initialize(
                 @host : String,
                 @path : String,
                 @user : String,
                 @pass : String,
                 @remote_site_path : String,
                 @public_path : String = "public",
                 @logger = Logger.new(STDOUT))
    @logger.level = Logger::DEBUG
  end

  # http://www.serv-u.com/ftp-commands-linux

  def exec(command : String, path : (String | Nil))
    sc = "ftp -n #{@host} <<END_SCRIPT\n"
    sc += "quote USER #{@user}\n"
    sc += "quote PASS #{@pass}\n"

    sc += "binary\n"

    sc += "cd #{@remote_site_path}\n"
    if path
      sc += "cd #{path}\n"
    end

    sc += command
    sc += "\n"

    sc += "quit\n"
    sc += "END_SCRIPT\n"

    sc += "echo $?\n"

    return `#{sc}`
  end

  def check_on_ftp(fp : String) : (Time | Nil)
    remote_path = File.dirname(fp)
    remote_name = File.basename(fp)

    # both works
    # res = exec(command: "modtime #{remote_name}", path: remote_path)
    res = exec(command: "modtime #{fp}", path: nil)

    r = res.gsub(fp, "").strip

    begin
      # TODO add kind https://crystal-lang.org/api/0.20.4/Time.html
      t = Time.parse(time: r, pattern: "%m/%d/%Y %H:%M:%S")
      return t
    rescue Time::Format::Error
      return nil
    end
  end

  def upload(f : String)
    remote_path = File.dirname(f)
    remote_name = File.basename(f)

    res = exec(command: "mkdir #{remote_path}", path: nil)
    res = exec(command: "put #{f}", path: nil)

    @logger.info("#{f} upload size #{File.size(f)}")

    remote_time = check_on_ftp(f)
    @logger.info("#{f} post upload REMOTE #{remote_time}")
  end

  def upload_if_needed(f : String)
    # we only check for real files
    remote_time = check_on_ftp(f)
    @logger.info("#{f} checked REMOTE #{remote_time}")

    if remote_time
      local_time = File.lstat(f).mtime

      if local_time > remote_time
        @logger.info("#{f} LOCAL is newer #{local_time}")
        return upload(f)
      else
        @logger.debug("#{f} LOCAL is not newer")
      end
    else
      return upload(f)
    end
  end

  def make_it_so
    Dir.cd(@public_path)
    Dir["**/*"].each do |f|
      if false == File.directory?(f)
        upload_if_needed(f)
        # return
      end
    end
    Dir.cd("..")
  end
end
