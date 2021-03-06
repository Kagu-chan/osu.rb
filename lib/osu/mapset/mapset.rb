module Osu
  module MapSet
    class MapSet

      attr_reader :beatmaps, :files, :storyboard

      def initialize(directory)
        @directory = directory
        @files = []
        @mapset_size = 0
        @beatmaps = []
        @storyboard = nil
        @storyboardFile = nil
      end

      def load()
        Find.find(@directory) { |path|
          if (!File.directory? path) then
            @files << path
            @mapset_size += FileTest.size(path)
          end
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

      def open_storyboard()
        @storyboardFile = @files.find { |file|
          file.match(/\.osb$/)
        }
        if @storyboardFile then
          @storyboard = Storyboard.factory(@storyboardFile)
        end
      end

      def used_files()
        return accumulate_used_files()
      end

      def unused_files()
        return map_given_files() - used_files()
      end

      def missing_files()
        given_files = @files.map() { |file|
          file.sub(@directory + '/', '')
        }
        used_files().select() { |file|
          !given_files.include?(file)
        }
      end

private
      def map_given_files()
        files = @files.map() { |file|
          file.sub(@directory + '/', '')
        }
        files.sort_by! { |e| e.downcase }

        files
      end

      def accumulate_used_files()
        files = [
          @storyboard.files,
          @storyboardFile.sub(@directory + '/', '')
        ]

        files << @beatmaps.map { |map| map.get_used_files() }
        files.flatten!

        files = files - [nil, '']
        files.sort_by! { |e| e.downcase }

        return files.uniq
      end
    end
  end
end