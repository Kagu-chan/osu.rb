module Osu
  module MapSet
    module BeatMap
      class BeatMap < Helper::LinesObject

        @@gametypeMap = {
          :'0' => {
            :type => Osu::MapSet::BeatMap::HitObject::Standard::HitObject,
            :decorator => Osu::MapSet::BeatMap::HitObject::Standard::Decorator
          },
          :'1' => {
            :type => Osu::MapSet::BeatMap::HitObject::Taiko::HitObject
          },
          :'2' => {
            :type => Osu::MapSet::BeatMap::HitObject::CatchTheBeat::HitObject,
            :decorator => Osu::MapSet::BeatMap::HitObject::CatchTheBeat::Decorator
          },
          :'3' => {
            :type => Osu::MapSet::BeatMap::HitObject::Mania::HitObject,
            :decorator => Osu::MapSet::BeatMap::HitObject::Mania::Decorator
          }
        }

        attr_reader :format,
                    :general,
                    :editor,
                    :metadata,
                    :difficulty,
                    :events,
                    :colors,
                    :timingpoints,
                    :hitobjects,
                    :background,
                    :video,
                    :storyboard,
                    :mp3

        def initialize(file)
          @filename = file
          @sections = {}
          @format = nil
          @general = nil
          @editor = nil
          @metadata = nil
          @difficulty = nil
          @events = nil
          @colors = nil
          @timingpoints = nil
          @hitobjects = nil
          @background = nil
          @video = nil
          @storyboard = nil
          @mp3 = nil

          super []
        end

        def load()
          file = File.open(@filename, 'rb')
          content = file.read().gsub(/\r\n?/, "\n")
          file.close()

          convert_from_stream(content)

          set_format()
          if (@format < 14)
            raise "Beatmap format v#{@format} is not supported!"
          end

          set_section_as('General', KeyValuePair)
          
          HitObjects.type = @@gametypeMap[@sections[:General].mode.to_sym][:type]

          set_section_as('Editor', KeyValuePair)
          set_section_as('Metadata', KeyValuePair)
          set_section_as('Difficulty', KeyValuePair)
          set_section_as('Events', Events)
          set_section_as('Colors', Section)
          set_section_as('TimingPoints', TimingPoints)
          set_section_as('HitObjects', HitObjects)

          @general      = @sections[:General]
          @editor       = @sections[:Editor]
          @metadata     = @sections[:Metadata]
          @difficulty   = @sections[:Difficulty]
          @events       = @sections[:Events]
          @timingpoints = @sections[:TimingPoints]
          @hitobjects   = @sections[:HitObjects]

          @mp3        = @general.audiofilename
          @background = @events.background
          @video      = @events.video
          @storyboard = @events.storyboard

          decorator = @@gametypeMap[@sections[:General].mode.to_sym][:decorator]
          if (decorator)
            @hitobjects.hitObjects.each { |hitObject|
              decorator.decorate(hitObject, self)
            }
          end
        end

        def get_used_files()
          files = [
            File.basename(@filename),
            @storyboard.files,
            @mp3,
            @hitobjects.get_used_files()
          ]

          files
        end

private
        def set_format()
          format_line = @lines[0]
          @format = format_line.gsub('osu file format v', '').to_i
        end

        def set_section_as(section, type)
          lines = read_from_to("[#{section}]", :empty)

          @sections[section.to_sym] = type.new(lines)
          @sections[section.to_sym].parse()
        end
      end
    end
  end
end
