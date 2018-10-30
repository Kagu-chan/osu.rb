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
              :'1'   => :SN,
              :'5'   => :SN,
              :'128' => :LN
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

            def update_samples()
              sampleMapping = {
                :'0' => nil,
                :'1' => :Normal,
                :'2' => :Soft,
                :'3' => :Drum
              }
              sampleConfig = @data[5].split(':')
              sampleConfig.shift() if (@type == :LN)
  
              @samples = [Sample.new({
                :sampleType     => @sampleType.to_i,
                :sampleSet      => sampleMapping[sampleConfig[0].to_sym],
                :sampleAddition => sampleMapping[sampleConfig[1].to_sym],
                :sampleSetID    => sampleConfig[2].to_i,
                :volume         => sampleConfig[3].to_i,
                :fileName       => sampleConfig[4].sub(/\n/, '')
              })]
            end

            def apply_timing_sections(timingPoints)
              @samples[0].timingSection = timingPoints.get_timing_section_for(@start)
            end
          end
        end
      end
    end
  end
end
