module Hapistrano
  class CLI
    def initialize(argv)
      if argv.first == "bootstrap" && argv.length >= 2
        Bootstrap.new(argv)
      else
        puts "You sent #{argv}"
      end
    end
  end
end
