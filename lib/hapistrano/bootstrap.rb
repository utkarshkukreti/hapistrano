module Hapistrano
  class Bootstrap
    def initialize(host)
      begin
        ssh = Net::SSH.start(host, 'root')
      rescue 
        password = HighLine.new.ask("Enter password: ") { |q| q.echo = '' }
        ssh = Net::SSH.start(host, 'root', password: password)
      end
      puts ssh.exec! "whoami"
    end
  end
end
