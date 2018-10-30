module Osu
  module MapSet
    module BeatMap
      module HitObject
        module CatchTheBeat
          class HitObject < Osu::MapSet::BeatMap::HitObject::HitObject

            @@typeMapping = {
              :'1' => :hs,
              :'2' => :slider,
              :'3' => :spinner
            }

            attr_reader :newCombo

            def update_type()
              type = @type.to_i

              @newCombo = (type - 4) > 3
              @type = @@typeMapping[type - 4]
            end
          end
        end
      end
    end
  end
end