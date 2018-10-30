module Osu
  module MapSet
    module BeatMap
      class KeyValuePair < Section

        def parse()
          @lines.each { |line|
            data = line.split(':')
            key = data[0].downcase
            value = data[1].strip

            instance_variable_set("@#{key}", value)

            self.class.send(:define_method, :"#{key}=") { |value|
              instance_variable_set("@#{key}", value)
            }

            self.class.send(:define_method, key.to_sym) {
              instance_variable_get("@#{key}")
            }
          }
        end
      end
    end
  end
end
