require "picon/version"

module Picon
  class Command
    def self.run(argv)
      new(argv).run
    end

    def initialize(argv)
      @argv = argv
    end

    def run
      case subcommand
      when "generate"
        Generator.run
      when "version"
        puts VERSION
      else
        abort "Usage: picon {generate|version}"
      end
    end

    private

    def subcommand
      @argv[0]
    end
  end
end
