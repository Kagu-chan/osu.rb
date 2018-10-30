module Osu
  module MapSet
    module BeatMap
      module HitObject
        module Standard
          class HitObject < Osu::MapSet::BeatMap::HitObject::HitObject

            @@typeMapping = {
              :'1' => :HitSound,
              :'2' => :Slider,
              :'3' => :Spinner
            }

            attr_reader :newCombo

            def initialize(line)
              super
            end

            def update_type()
              type = @type.to_s.to_i

              @newCombo = (type - 4) > 3
              @type = @@typeMapping[(@newCombo ? type - 4 : type).to_s.to_sym]
            end

            ##
            # @TODO: Update for sliders and spinners
            def update_samples()
              sampleConfig = @data[5].split(':')
              sampleConfig.shift() if (@type == :LN)
  
              @samples = [Sample.new({
                :sampleType     => @sampleType,
                :sampleSet      => sampleConfig[0],
                :sampleAddition => sampleConfig[1],
                :sampleSetID    => sampleConfig[2],
                :volume         => sampleConfig[3],
                :fileName       => sampleConfig[4].sub(/\n/, '')
              })]
            end

            ##
            # @TODO: Update for sliders and spinners
            def apply_timing_sections(timingPoints)
              @samples[0].timingSection = timingPoints.get_timing_section_for(@start)
            end
          end
        end
      end
    end
  end
end