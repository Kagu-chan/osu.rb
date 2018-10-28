module Osu
  module MapSet
    module BeatMap
      class HitObjects < Section

        @@type = nil

        attr_reader :hitObjects

        def initialize(lines)
          super

          @hitObjects = []
        end

        def parse()
          @lines.each { |line|
            @hitObjects << @@type.new(line)
          }
        end

        def self.type=(type)
          @@type = type
        end
      end
    end
  end
end
