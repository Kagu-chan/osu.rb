module Osu
  module MapSet
    class Storyboard < LinesObject

      attr_reader :files, :bg, :video

      def initialize(lines)
        super

        @bg = nil
        @video = nil
        @files = []
      end

      def find_files()
        find_bg()
        find_video()
        find_images()
        find_sounds()

        @files << @bg if @bg
        @files << @video if @video

        @files = @files.uniq
      end

    private
      def find_bg()
        lines = read_from_to(:"//Background and Video events", :"//Break Periods")
        lines.each { |line|
          l = line.gsub(/0,0,"(.*)",0,0/, '\1')
          if l != line
            @bg = l
            break
          end
        }
      end

      def find_video()
        lines = read_from_to(:"//Background and Video events", :"//Break Periods")
        lines.each { |line|
          l = line.gsub(/Video,\d+,"(.*)"/, '\1')
          if l != line
            @video = l
            break
          end
        }
      end

      def find_images()
        lines = read_from_to(:"//Background and Video events")

        lines.each { |line|
          if (line.start_with? 'Sprite')
            @files << line.gsub(/Sprite,\w+,\w+,"(.*)",-?\d+,-?\d+/, '\1')
          end
        }
      end

      def find_sounds()
        lines = read_from_to(:"//Background and Video events")

        lines.each { |line|
          if (line.start_with? 'Sample')
            @files << line.gsub(/Sample,\d+,\d,"(.*)",\d+/, '\1')
          end
        }
      end

    end
  end
end
