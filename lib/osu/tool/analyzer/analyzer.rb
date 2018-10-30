module Osu
  module Tool
    class Analyzer

      def self.run(args)
        if (args == ['-help']) then
          self.help()
        else
          self.new(*args).run()
        end
      end

      def initialize(mapset, *args)
        @mapset_location = mapset
        @maps = []

        loop {
          arg = args[0]
          if arg && arg.start_with?('-') && arg != '-all' then
            option, value = args.shift().sub(/^-/, '').split('=')

            instance_variable_set("@#{option}", value || true)
          else
            break
          end
        }

        if args == ['-all'] then
          @maps = []
        else
          @maps = args
        end
      end

      def run()
        @mapset = Osu::MapSet::MapSet.new(@mapset_location)
        @mapset.load()

        @mapset.open_storyboard() if !@skipstoryboard

        if @maps.size == 0 then
          @mapset.load_all_beatmaps()
        else
          @maps.each() { |map| @mapset.load_beatmap(map) }
        end
      end

private
      def self.help()
        puts <<TXT
Usage: ruby osr.rb analyzer MAP [OPTIONS] DIFFS|-all
  MAP        => beatmap directory

  OPTIONS    =>
                -skipstoryboard => If true, no attempt is made to load a storyboard

  DIFFS|-all => list of difficulties to respect.
                type `-all` to load all difficulties

TXT
      end
    end
  end
end
