#
class Tremolite::Uploader
  def initialize(
      @host : String,
      @path : String,
      @user : String,
      @pass : String,
      @remote_site_path : String,
      @public_path : String = "public"
    )

  end

  def exec(command : String, path : (String | Nil))
    sc = "ftp -n #{@host} <<END_SCRIPT\n"
    sc += "quote USER #{@user}\n"
    sc += "quote PASS #{@pass}\n"

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

  def check_on_ftp(fp : String)
    remote_path = File.dirname(fp)
    remote_name = File.basename(fp)

    res = exec(command: "modtime #{remote_name}", path: remote_path)
    res = exec(command: "modtime #{fp}", path: nil)
    puts "#{fp} - #{res}"

    #res = exec
  end

  def make_it_so
    Dir.cd(@public_path)
    Dir["**/*"].each do |f|
      if false == File.directory?(f)
        # we only check for real files
        result = check_on_ftp(f)

        return
      end
    end
    Dir.cd("..")
  end

# modtime #{@file}
# puts #{file}

end
