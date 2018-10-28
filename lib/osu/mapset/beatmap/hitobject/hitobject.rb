module Osu
  module MapSet
    module BeatMap
      module HitObject
        class HitObject
          
          attr_reader :row,
                      :position,
                      :start,
                      :end,
                      :type,
                      :sample
          
          def initialize(line)
            data = line.split(',')

            @row = 0
            @position     = {
                              :x => data[0].to_i,
                              :y => data[1].to_i
                            }
            @start        = data[2].to_i
            @end          = @start
            @type         = { :'1' => :hs, :'5' => :hs, :'128' => :ln }[data[3].to_sym]
            
            sampleType   = data[4].to_i
            sampleConfig = data[5].split(':')

            if (@type == :ln)
              @end = sampleConfig.shift().to_i
            end

            @sample = Sample.new(sampleType, sampleConfig)
          end
          
          def set_row_by_circlesize(cs)
            @row = @position[:x] / (512 / cs) + 1
          end
        end
      end
    end
  end
end
