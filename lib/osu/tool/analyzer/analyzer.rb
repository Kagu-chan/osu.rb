module Osu
  module Tool
    class Analyzer

      def self.run(args)
        if (args == ['-help']) then
          self.help()
        end
      end

private
      def self.help()
        puts <<TXT
Usage: ruby osr.rb analyzer MAP [OPTIONS] [DIFFS|-all]
  MAP        => beatmap directory
  OPTIONS    => none so far
  DIFFS|-all => list of difficulties to respect.
                type `-all` to load all difficulties

TXT
      end
    end
  end
end
