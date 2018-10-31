module Osu
  module MapSet
    class Storyboard < Helper::LinesObject

      attr_reader :files, :background, :video

      def self.factory(file)
        file = File.open(file, 'rb')
        content = file.read().gsub(/\r\n?/, "\n")
        file.close()

        instance = self.new(content)
      end

      def initialize(lines)
        super

        @background = nil
        @video = nil
        @files = []
      end

      def find_files()
        find_background()
        find_video()
        find_images()
        find_sounds()

        @files << @background if @background
        @files << @video if @video

        @files = @files.uniq
      end

private
      def find_background()
        lines = read_from_to(:"//Background and Video events", :"//Break Periods")
        lines.each { |line|
          l = line.gsub(/0,0,"(.*)",0,0\n/, '\1')
          if l != line
            @background = l.gsub(/\\/, '/')
            break
          end
        }
      end

      def find_video()
        lines = read_from_to(:"//Background and Video events", :"//Break Periods")
        lines.each { |line|
          l = line.gsub(/Video,\d+,"(.*)"\n/, '\1')
          if l != line
            @video = l.gsub(/\\/, '/')
            break
          end
        }
      end

      def find_images()
        lines = read_from_to(:"//Background and Video events")

        lines.each { |line|
          if (line.start_with? 'Sprite')
            @files << line
              .gsub(/Sprite,\w+,\w+,"(.*)",-?\d+,-?\d+\n/, '\1')
              .gsub(/\\/, '/')
          end
        }
      end

      def find_sounds()
        lines = read_from_to(:"//Background and Video events")

        lines.each { |line|
          if (line.start_with? 'Sample')
            @files << line
              .gsub(/Sample,\d+,\d,"(.*)",\d+\n/, '\1')
              .gsub(/\\/, '/')
          end
        }
      end
    end
  end
end
