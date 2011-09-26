module Hapistrano
  class Bootstrap
    def initialize(host)
      Net::SSH.start(host, 'root') do |ssh|
        puts ssh.exec! "whoami"
      end
    end
  end
end
