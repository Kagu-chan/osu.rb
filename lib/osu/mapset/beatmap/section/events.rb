module Osu
  module MapSet
    module BeatMap
      module Section
        class Events < Section

          attr_reader :storyboard, :background, :video

          def initialize(lines)
            super

            @storyboard = Osu::MapSet::Storyboard.new(@lines)
          end

          def parse()
            @storyboard.find_files()

            @background = @storyboard.background
            @video = @storyboard.video
          end
        end
      end
    end
  end
end
