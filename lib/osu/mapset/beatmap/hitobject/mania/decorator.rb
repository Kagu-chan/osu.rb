module Osu
  module MapSet
    module BeatMap
      module HitObject
        module Mania
          class Decorator < Osu::MapSet::BeatMap::HitObject::Decorator

            def self.decorate(hitObject, beatMap)
              super

              hitObject.update_row(beatMap.difficulty.circlesize.to_i)
            end

          end
        end
      end
    end
  end
end