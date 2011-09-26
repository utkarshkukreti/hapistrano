module Hapistrano
  class Bootstrap
    def initialize(host)
      begin
        ssh = Net::SSH.start(host, 'root')
      rescue 
        puts "Enter password: "
        password = STDIN.gets.chomp
        ssh = Net::SSH.start(host, 'root', password: password)
      end
      puts ssh.exec! "whoami"
    end
  end
end
