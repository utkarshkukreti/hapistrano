module Hapistrano
  class Bootstrap
    def initialize(argv)
      host = argv.shift
      @verbose = argv.shift
      begin
        @ssh = Net::SSH.start(host, 'root')
      rescue 
        password = HighLine.new.ask("Enter password: ") { |q| q.echo = '' }
        @ssh = Net::SSH.start(host, 'root', password: password)
      end

      log "Creating user deploy"
      exec 'whoami'
      exec "useradd -m -d /var/apps/ --shell /bin/bash deploy"
      exec "echo 'deploy ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"

      log "Adding your ssh key for user deploy"
      exec "mkdir /var/apps/.ssh"
      ssh_key = File.read(File.expand_path("~/.ssh/id_rsa.pub"))
      exec "echo #{esc ssh_key} >> /var/apps/.ssh/authorized_keys"
      @ssh.close

      log "Logging in as user deploy"
      @ssh = Net::SSH.start(host, 'deploy')
      exec 'whoami'

      log "Installing dependencies"
      exec 'sudo apt-get update'
      exec 'sudo apt-get install -y git-core build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev libcurl4-openssl-dev'

      log "Installing RVM"
      exec 'bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)'
      exec 'cp ~/.bashrc ~/.bashrc_tmp && echo "[[ -s \"$HOME/.rvm/scripts/rvm\" ]] && source \"$HOME/.rvm/scripts/rvm\"" > ~/.bashrc && cat ~/.bashrc_tmp >> ~/.bashrc && rm ~/.bashrc_tmp'
      exec '. ~/.bashrc'

      log "Installing ruby 1.9.2"
      exec 'rvm install 1.9.2'
      exec 'rvm --default use 1.9.2'

      log "Installing passenger with nginx"
      exec 'gem install passenger'
      exec 'rvmsudo passenger-install-nginx-module --auto --auto-download --prefix="/opt/nginx"'

      nginx_init_d = File.read(File.expand_path('../templates/nginx-init.d.sh', __FILE__))
      exec "echo #{esc(nginx_init_d)} > nginx-init.d.sh"
      exec 'sudo mv nginx-init.d.sh /etc/init.d/nginx'
      exec 'sudo chmod +x /etc/init.d/nginx'
      exec 'sudo /usr/sbin/update-rc.d -f nginx defaults'
      exec 'sudo service nginx restart'

      log "Installing postgresql"
      exec 'sudo apt-get install -y postgresql-8.4'

      # Use utf-8
      exec 'sudo pg_dropcluster --stop 8.4 main'
      exec 'sudo pg_createcluster --start -e UTF-8 8.4 main'
      exec 'sudo /etc/init.d/postgresql-8.4 restart'
      exec 'sudo su -c "createuser -rds deploy" postgres'
      exec 'sudo su -c "createdb hello_world" postgres'
    end

    private
    def exec(cmd)
      puts "*** Executing #{cmd}"
      @ssh.exec!(cmd) do |channel, stream, data|
        puts data if @verbose
      end
    end

    def esc(cmd)
      return "''" if cmd.empty? 
      cmd.gsub(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1").gsub(/\n/, "'\n'")
    end
  end
end
