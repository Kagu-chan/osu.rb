module Osu
  module MapSet
    module BeatMap
      class TimingSection
          
        attr_reader :start,
                    :end,
                    :value,
                    :signature,
                    :sampletype,
                    :sampleset,
                    :volume,
                    :volume,
                    :kiai,
                    :bpm,
                    :sv
        
        def initialize(line_a, line_b)
          data_a = line_a.split(',')
          data_b = line_b ? line_b.split(',') : ['0']

          @start      = data_a[0].to_i
          @end        = data_b[0].to_i
          @value      = data_a[1]
          @signature  = data_a[2].to_i
          @sampletype = %w(Normal Soft Drum)[data_a[3].to_i - 1].to_sym
          @sampleset  = data_a[4].to_i
          @volume = data_a[5].to_i
          @type = data_a[6] == '1' ? :timing : :inherit
          @kiai = data_a[7] == '1'
          @bpm = 0
          @sv = 1.0

          if inherited?
            @sv = -100.to_f / @value.to_f
          else
            @bpm = (60000 / @value.to_f).round(3)
          end
        end

        def inherited?()
          return @type == :inherit
        end
        
        def bpm=(value)
          raise("Numeric expected") unless value.is_a?(Numeric)
          @bpm = value
        end
        
        def end=(value)
          raise("Numeric expected") unless value.is_a?(Numeric)
          @end = value
        end
      end
    end
  end
end
