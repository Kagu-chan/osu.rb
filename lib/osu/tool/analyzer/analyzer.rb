module Osu
  module Tool
    class Analyzer < Tool

      def initialize(mapset, *args)
        ##
        # option skipstoryboard (boolean)
        #
        # if true, no storyboard will be loaded
        @skipstoryboard = false

        ##
        # option all (boolean)
        #
        # If true, beatmap argument will be ignored and all maps will be loaded
        @all = false

        @mapset_location = mapset
        @maps = []

        Helper::Console.parse_arguments(self, {
          :skipstoryboard => [:boolean, true],
          :all            => [:boolean, true]
        }, args)

        @maps = @all ? [] : args
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

protected
      def self.help()
        puts <<TXT
Usage: ruby osr.rb analyzer MAP [OPTIONS] [DIFFS[]]
  MAP        => beatmap directory

  OPTIONS   =>
              -skipstoryboard => If true, no attempt is made to load a storyboard
              -all            => If true, DIFFS argument will be ignored and all maps will be loaded

  DIFFS[]   => list of difficulties to respect

TXT
      end
    end
  end
end
