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
    end

    def exec(cmd)
      puts "*** Executing #{cmd}"
      puts @ssh.exec!(cmd)
    end
  end
end
