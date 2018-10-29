module Osu
  module MapSet
    module BeatMap
      module HitObject
        module Mania
          class HitObject < Osu::MapSet::BeatMap::HitObject::HitObject

            ##
            # format v14:   SN: 192,192,34977,1,2,0:0:0:0:
            #               LN: 64,192,34977,128,0,35636:0:0:0:0:

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

            def update_noteEnd()
              @end = @data[5].split(':')[0]
            end

            def update_sample()
              sampleConfig = @data[5].split(':')
              sampleConfig.shift() if (@type == :ln)
  
              @samples = [Sample.new(@sampleType, sampleConfig)]
            end
          end
        end
      end
    end
  end
end
