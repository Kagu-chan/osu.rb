module Osu
  module MapSet
    class MapSet

      attr_reader :beatmaps, :files

      def initialize(directory)
        @directory = directory
        @files = []
        @mapset_size = 0
        @beatmaps = []
      end

      def load()
        Find.find(@directory) { |path|
          @files << path
          @mapset_size += FileTest.size(path)
        }
      end

      def load_beatmap(name)
        filename = nil

        @files.each { |path|
          if path.end_with? "[#{name}].osu"
            filename = path
            break
          end
        }

        @beatmaps << BeatMap::BeatMap.new(filename)
      end

      def load_all_beatmaps()
        @files.each { |path|
          if path.match /\[.*\]\.osu$/
            @beatmaps << BeatMap::BeatMap.new(path)
          end
        }
      end
    end
  end
end