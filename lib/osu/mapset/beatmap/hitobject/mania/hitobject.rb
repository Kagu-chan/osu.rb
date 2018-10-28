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
          end
        end
      end
    end
  end
end