module Osu
  module MapSet
    module BeatMap
      class TimingPoints < Section

        attr_reader :timingSections

        def initialize(lines)
          super

          @timingSections = []
        end

        def parse()
          @lines.each_with_index { |line, index|
            next_index = index + 1
            next_line = @lines.size >= next_index ? @lines[next_index] : '0'

            @timingSections << TimingSection.new(line, next_line)
          }
        end

        ##
        # Get the timing section for a specific object
        #
        # Due to rounding issues the first hit objects may be shiftet by a millisecond
        def get_timing_section_for(offset)
          @timingSections.find { |section, index|
            start = section.start

            # Handle the shiftet offsets
            if index == 0
              start -= 1
            end

            start <= offset && (section.end == 0 || section.end > offset)
          }
        end
      end
    end
  end
end
