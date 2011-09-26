module Hapistrano
  class Bootstrap
    def initialize(host)
      begin
        @ssh = Net::SSH.start(host, 'root')
      rescue 
        password = HighLine.new.ask("Enter password: ") { |q| q.echo = '' }
        @ssh = Net::SSH.start(host, 'root', password: password)
      end
      exec 'whoami'
      exec "useradd -m -d /var/apps/ deploy"
      exec "echo 'deploy ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"

      exec "mkdir /var/apps/.ssh"
      ssh_key = File.read(File.expand_path("~/.ssh/id_rsa.pub"))
      exec "echo #{esc ssh_key} >> /var/apps/.ssh/authorized_keys"
      @ssh.close

      @ssh = Net::SSH.start(host, 'deploy')
      exec 'whoami'
      exec 'sudo apt-get update'
      exec 'sudo apt-get install -y git-core build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev'
    end

    private
    def exec(cmd)
      puts "*** Executing #{cmd}"
      puts @ssh.exec!(cmd)
    end

    def esc(cmd)
      return "''" if cmd.empty? 
      cmd.gsub(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1").gsub(/\n/, "'\n'")
    end
  end
end
