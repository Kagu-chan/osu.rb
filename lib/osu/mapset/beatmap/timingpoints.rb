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
        # Due to rounding issues it may be shiftet by a millisecond
        def get_timing_section_for(offset)
          offset_l = offset - 1
          offset_r = offset + 1

          index = @timingSections.find_index() { |section|
            start_before = section.start <= offset_r
            end_after    = section.end > offset_l

            start_before && end_after
          }

          return index ? @timingSections[index] : false
        end
      end
    end
  end
end
