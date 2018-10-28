module Osu
  module MapSet
    module BeatMap
      class Events < Section

        def initialize(lines)
          super

          @storybaord = Osu::MapSet::Storyboard.new(@lines)
        end

        def parse()
          @storybaord.find_files()
        end
      end
    end
  end
end
