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
      exec "useradd -m -d /var/apps/ --shell /bin/bash deploy"
      exec "echo 'deploy ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"

      exec "mkdir /var/apps/.ssh"
      ssh_key = File.read(File.expand_path("~/.ssh/id_rsa.pub"))
      exec "echo #{esc ssh_key} >> /var/apps/.ssh/authorized_keys"
      @ssh.close

      @ssh = Net::SSH.start(host, 'deploy')
      exec 'whoami'
      exec 'sudo apt-get update'
      exec 'sudo apt-get install -y git-core build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev libcurl4-openssl-dev'

      exec 'bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)'
      exec 'cp ~/.bashrc ~/.bashrc_tmp && echo "[[ -s \"$HOME/.rvm/scripts/rvm\" ]] && source \"$HOME/.rvm/scripts/rvm\"" > ~/.bashrc && cat ~/.bashrc_tmp >> ~/.bashrc && rm ~/.bashrc_tmp'
      exec '. ~/.bashrc'

      exec 'type rvm'
      exec 'rvm install 1.9.2'
      exec 'rvm --default use 1.9.2'

      exec 'gem install passenger'
      exec 'rvmsudo passenger-install-nginx-module --auto --auto-download --prefix="/opt/nginx"'

      nginx_init_d = File.read(File.expand_path('../templates/nginx-init.d.sh', __FILE__))
      exec "echo #{esc(nginx_init_d)} > nginx-init.d.sh"
      exec 'sudo mv nginx-init.d.sh /etc/init.d/nginx'
      exec 'sudo chmod +x /etc/init.d/nginx'
      exec 'sudo /usr/sbin/update-rc.d -f nginx defaults'
      exec 'sudo service nginx start'
    end

    private
    def exec(cmd)
      puts "*** Executing #{cmd}"
      @ssh.exec!(cmd) do |channel, stream, data|
        puts data
      end
    end

    def esc(cmd)
      return "''" if cmd.empty? 
      cmd.gsub(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1").gsub(/\n/, "'\n'")
    end
  end
end
