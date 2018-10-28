module Osu
  module MapSet
    module BeatMap
      module HitObject
        module Mania
          class HitObject < Osu::MapSet::BeatMap::HitObject::HitObject

            @@typeMapping = {
              :'1'   => :hs,
              :'5'   => :hs,
              :'128' => :ln
            }

            attr_reader :row

            def initialize(line)
              super

              @row = 0
            end

            def update_type()
              @type = @@typeMapping[@type]
            end

            def update_row(circleSize)
              @row = @position[:x] / (512 / circleSize) + 1
            end
          end
        end
      end
    end
  end
end