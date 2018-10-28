require_relative 'lib\numeric'

require_relative 'lib/osu/storyboard'
require_relative 'lib/osu/hitsound'

class HitObject
    
    attr_reader :ln, :row, :position, :end_position, :hitsound
    
    def initialize(line, difficulty)
        data = line.split(",")
        
        @row = data[0].to_i / (512 / difficulty[:"CircleSize"].to_i) + 1
        @position = data[2]
        
        @ln = data[5].split(":").size == 6
    end
    
end

class TimingSection
    
    attr_reader :offset, :until, :inherited, :sv, :bpm, :quarters, :sampletype, :sampleset, :volume, :kiai
    
    def initialize(line, nextline)
        data = line.split(",")
        nextdata = nextline.split(",")
        
        @offset = data[0]
        @until = nextdata[0]
        
        @inherited = data[6] == "0"
        @value = data[1]
        
        @sv = 1.0
        @bpm = 0
        if @inherited
            @sv = -100.to_f / @value.to_f
        else
            @bpm = (60000 / @value.to_f).round(3)
        end
        
        @quarters = data[2].to_i
        @sampletype = case data[3].to_i
            when 1 then :normal
            when 2 then :soft
            when 3 then :drum
        end
        @sampleset = data[4].to_i
        @volume = data[5].to_i
        
        @kiai = data[7] == "1"
    end
    
    def bpm=(value)
        raise("Numeric expected") unless value.is_a?(Numeric)
        @bpm = value
    end
    
    def until=(value)
        raise("Numeric expected") unless value.is_a?(Numeric)
        @until = value
    end
    
end

class Diff
    
    attr_reader :diff, :general, :meta, :music, :timings, :kiais, :kiai_sum, :hits, :difficulty, :sb, :file, :files, :storyboard
    
    def initialize(dir, filename)
        @file = filename
        file = File.open("#{dir}/#{filename}", "rb")
        @input = file.read().gsub(/\r\n?/, "\n")
        file.close
        
        read_general()
        read_meta()
        read_difficulty()
        read_timing()
        read_hitobjects()
        check_storyboard()
        read_storyboard()
        collect_used_files()

        @diff = @meta[:Version].to_sym
    end
    
    def read_general()
        @general = {}
        
        lines = read_from_to(:"[General]", :"[Editor]")
        lines.each { |l|
            next if l == "\n"
            data = l.split(": ", 2)
            @general[data[0].to_sym] = data[1].sub(/\n/, "")
        }
    end
    
    def read_meta()
        @meta = {}
        
        lines = read_from_to(:"[Metadata]", :"[Difficulty]")
        lines.each { |l|
            next if l == "\n"
            data = l.split(":", 2)
            @meta[data[0].to_sym] = data[1].sub(/\n/, "")
        }
    end
    
    def read_difficulty()
        @difficulty = {}
        
        lines = read_from_to(:"[Difficulty]", :"[Events]")
        lines.each { |l|
            next if l == "\n"
            data = l.split(":", 2)
            @difficulty[data[0].to_sym] = data[1].sub(/\n/, "")
        }
    end
    
    def read_timing()
        @timings = []
        
        lines = read_from_to(:"[TimingPoints]", :"[HitObjects]")
        lines.each_index { |i|
            l = lines[i].sub(/\n/, "")
            next if l == ""
            
            nl = lines[i+1].sub(/\n/, "")
            nl = "0" if nl == ""
            
            @timings << TimingSection.new(l, nl)
        }
        
        last = 0
        @timings.each { |timing| 
            if !timing.inherited
                last = timing.bpm
            else
                timing.bpm = last
            end
        }
        
        analyze_kiai()
    end
    
    def analyze_kiai()
        kiais = @timings.select() { |timing| timing.kiai }
        times = []
        kiais.each { |k| times << [k.offset, k.until] }
        
        @kiais = []
        
        from = nil
        times.each { |time|
            from = time[0] if from.nil?
            according_time = times.find() { |t| t[0] == time[1] }
            if according_time.nil?
                @kiais << [from, time[1]]
                from = nil
            end
        }
    end
    
    def calc_kiai_sum()
        @kiai_sum = 0
        @kiais.each { |kiai| @kiai_sum += (kiai[1].to_i - kiai[0].to_i) }
    end
    
    def read_hitobjects()
        @hits = []
        
        lines = read_from_to(:"[HitObjects]", :end)
        lines.each { |l|
            next if l == "\n"
            
            @hits << HitObject.new(l, @difficulty)
        }
    end

    def check_storyboard()
        @sb = false

        @sb = @sb || check_line_cap(:"//Background and Video events", :"//Break Periods", 1)
        @sb = @sb || check_line_cap(:"//Storyboard Layer 0 (Background)", :"//Storyboard Layer 1 (Fail)")
        @sb = @sb || check_line_cap(:"//Storyboard Layer 1 (Fail)", :"//Storyboard Layer 2 (Pass)")
        @sb = @sb || check_line_cap(:"//Storyboard Layer 2 (Pass)", :"//Storyboard Layer 3 (Foreground)")
        @sb = @sb || check_line_cap(:"//Storyboard Layer 3 (Foreground)", :"//Storyboard Sound Samples")
        @sb = @sb || check_line_cap(:"//Storyboard Sound Samples", :"[TimingPoints]")
    end

    def read_storyboard()
        @storyboard = Storyboard.new(read_from_to(:"[Events]", :"[TimingPoints]"))

        @storyboard.find_files()
    end
    
    def music=(hash)
        raise("Hash expected") unless hash.is_a?(Hash)
        
        tdat = hash[:Duration].split(":").map() { |e| e.to_i }
        tdat[2] *= 1000
        tdat[1] *= 1000 * 60
        tdat[0] *= 1000 * 60 * 60
        
        @music = hash
        @music[:DurationMS] = tdat.inject { |sum, x| sum + x }
    end

private
    def check_line_cap(from, to, max=0)
        lines = read_from_to(from, to)

        return lines.size > max
    end

    def collect_used_files()
        @files = []

        @files << @general[:AudioFilename]
        @files << @storyboard.files

        @files = @files.uniq
    end

    def read_from_to(from, to=:end)
        lines = []
        
        _start = false
        @input.each_line { |line|
            unless _start
                _start = line.start_with?(from.to_s)
            else
                if to == :end
                    lines << line
                else
                    break if line.start_with?(to.to_s)
                    lines << line
                end
            end
        }
        
        return lines
    end
end

class Comparer
    
    def initialize(*args)
        @directory = args.shift()
        @diffnames = args
        @filenames = []
        @diffs = []
        @found = false
        @files = []
        @used_files = []
        
        files = Dir.entries(@directory) - [".", "..", File.basename(__FILE__)]
        @diffnames.each { |dname|
            includeString = "[#{dname}]"
            if dname == '-all'
                includeString = "].osu"
            end
            files.each { |f|
                @filenames << f if f.include?(includeString)
            }
        }
        puts "Comparing:"
        @filenames.each { |fname|
            puts "\t#{fname}"
            @diffs << Diff.new(@directory, fname)
        }
        
        analyze_files()

        check_global_sb()

        check_equalities()
        check_general()
        check_meta()
        # analyze_music()
        # check_music()
        # check_timings()
        # check_hits()

        @diffs.each { |diff| 
            @used_files << diff.files
        }
        @used_files = @used_files.uniq
    end

    def analyze_files()
        excludes = [".", ".."] + @filenames + [get_sb_filename()]

        analyze_dir(@files, @directory, excludes)
    end

    def get_sb_filename()
        diff = @diffs[0]
        file = diff.file
        dname = diff.diff

        return file.sub(/\s\[#{dname}\]+\.osu/i, '.osb')
    end

    def check_global_sb()
        fname = "#{@directory}\\" + get_sb_filename()
        @sb = File.exist? fname
    end

    def check_general()
        @diffs.each { |diff|
            empty()
            puts "General check for #{diff.diff}\n"
            
            should_be(diff, :general, :Mode, "3")
            should_be(diff, :general, :LetterboxInBreaks, "0")
            should_be(diff, :general, :SpecialStyle, "0")

            should_be(diff, :general, :WidescreenStoryboard, @sb || diff.sb ? "1" : "0")

            if diff.general[:PreviewTime].to_i < 0
                @found = true
                puts ("PreviewTime not set!!!")
            end
             
            no_issues_found?()
        }
    end
    
    def check_equalities()
        empty()
        puts("Check some necessary data...\n")
        
        should_be_same(:general, :AudioFilename)
        should_be_same(:general, :AudioLeadIn)
        should_be_same(:general, :PreviewTime)
        check_sb_consistency()
        
        no_issues_found?()
    end
    
    def check_meta()
        empty()
        puts("Metadata check...\n")
        
        should_be_same(:meta, :Title)
        should_be_same(:meta, :TitleUnicode)
        should_be_same(:meta, :Artist)
        should_be_same(:meta, :ArtistUnicode)
        should_be_same(:meta, :Creator)
        should_be_same(:meta, :Source)
        should_be_same(:meta, :Tags)
        
        no_issues_found?()
    end
    
    def analyze_music()
        empty()
        puts "Analyze MP3 File - this may take a while..."
        empty()
        result = `mcheck.exe \"#{@directory}/#{@diffs[0].general[:AudioFilename]}\"`
        
        data = {}
        result.each_line { |l|
            data[:FileName] = l.split(": ", 2)[1].sub(/\n/, "") if l.start_with?("File Name")
            data[:FileSize] = l.split(": ", 2)[1].sub(/\n/, "") if l.start_with?("File Size")
            data[:AudioBitrate] = l.split(": ", 2)[1].sub(/\n/, "") if l.start_with?("Audio Bitrate")
            data[:Duration] = l.split(": ", 2)[1].sub(/\n/, "").sub(/\s\(approx\)/, "") if l.start_with?("Duration")
        }
        data.each_pair { |k, v| puts "#{k} => #{v}"}
        
        @diffs.each { |diff|
            diff.music = data
            diff.timings[diff.timings.size-1].until = diff.music[:DurationMS]
            diff.kiais.select do |k| k[1] == "0" end.each { |k| k[1] = diff.music[:DurationMS] }
            diff.calc_kiai_sum()
        }
        
        puts("Duration in MS => #{@diffs[0].music[:DurationMS]}")
    end
    
    def check_music()
        empty()
        puts("Check for issues in MP3...")
        
        music = @diffs[0].music
        bitrate = music[:AudioBitrate].sub(/\s.*/, "").to_i
        
        if bitrate > 192
            puts ("Music Bitrate is too high! It should be CBR 192 KB/s or less OR VBR 1.0")
            @found = true
        end
        
        if music[:DurationMS] < 45000
            puts ("Your MP3 is very short. Beatmaps should be 45 seconds at minimum!")
            @found = true
        end
        
        no_issues_found?()
    end
    
    def check_timings()
        empty()
        puts "Check Timings..."
        
        timing_points = {}
        inherit_points = {}
        kiai_points = {}
        @diffs.each { |diff| 
            timing_points[diff.diff] = diff.timings.select() { |timing| !timing.inherited }
            inherit_points[diff.diff] = diff.timings.select() { |timing| timing.inherited }
        }
        
        continue = true
        i = 0
        loop {
            found = false
            reference = nil
            timing_points.each_pair { |diff, point|
                if point[i]
                    found = true
                    if reference.nil?
                        reference = [diff, point[i]]
                    else
                        current = point[i]
                        if current.offset != reference[1].offset || current.bpm != reference[1].bpm
                            puts "Timingpoint #{i+1} (Offset = #{reference[1].offset}; BPM = #{reference[1].bpm}; Diff: #{reference[0]}) conflicts with \n\tTimingpoint #{i+1} (Offset = #{point[i].offset}; BPM = #{point[i].bpm}) in #{diff} Diff\n\n"
                            @found = true
                        end
                    end
                end
            }
            break unless found
            i += 1
        }
        
        reference = nil
        timing_points.each_pair { |diff, point|
            if reference.nil?
                reference = point.size
            elsif reference != point.size
                puts("You're using different amount of uninherited timing sections this mapset!")
                @found = true
                break
            end
        }
        
        if @found
            timing_points.each_pair { |diff, point|
                puts ("For '#{diff}' you used #{point.size} timing sections and #{inherit_points[diff].size} inherited sections")
            }
        else
            diff, point = timing_points.first()
            puts ("You used #{point.size} timing section(s) and #{inherit_points[diff].size} inherited section(s)")
        end
        
        
        kiais = @diffs.collect() { |diff| diff.kiais }
        if kiais.uniq.size > 1
            puts ("The KIAI-Timings are not consistent through the Mapset!")
            @found = true
        end
        
        @diffs.each { |diff|
            kiai = ((diff.kiai_sum / diff.music[:DurationMS].to_f) * 100).round(2)
            if kiai > 33.33
                puts "KIAI-Time in #{diff.diff} is #{kiai}% of songs duration, it should be at max 1/3 - consider reducing it"
                @found = true
            end
            if diff.kiais.select do |k| k[1] == diff.music[:DurationMS] end.size > 0
                puts "KIAI-Time in #{diff.diff} goes until end of song. Are you sure about this?"
                @found = true
            end
        }
        
        no_issues_found?()
    end
    
    def check_hits()
        empty()
        puts "Checking Hitobjects..."
        
        @diffs.each { |diff|
            sno = diff.hits.select() { |h| !h.ln}
            lno = diff.hits.select() { |h| h.ln}
            puts "#{diff.diff} [#{diff.difficulty[:"CircleSize"]}K]\n\tThis Diff contains #{diff.hits.size} Hitobjects (Short Note: #{sno.size}, Long Note: #{lno.size})"
            
            unless diff.hits.size == 0
                max_hits = 0
                for i in 1..diff.difficulty[:"CircleSize"].to_i
                    objects = diff.hits.select { |h| h.row == i }
                    max_hits = objects.size if objects.size > max_hits
                end
                format = "%#{max_hits.to_s.size.to_s}d"
                
                for i in 1..diff.difficulty[:"CircleSize"].to_i
                    objects = diff.hits.select { |h| h.row == i }
                    percent = (objects.size.to_f/diff.hits.size*100).round(2)
                    puts("\t\t#{sprintf(format, objects.size)} on Row #{i} (#{percent.percent}%)")
                end
            else
                puts "\tDiff #{diff.diff} is unrankable since it has no hitobjects."
                @found = true
            end
            empty()
        }
    end

    def check_sb_consistency()
        diffs_w = (@diffs.select { |diff| diff.sb }).map { |diff| diff.diff }
        diffs_wo = (@diffs.select { |diff| !diff.sb }).map { |diff| diff.diff }

        return if diffs_w.size == 0 || diffs_wo.size == 0

        puts "#{diffs_w.join ', '} has diff specific storyboard; #{diffs_wo.join ', '} has not. Is this intended?"
        @found = true
    end

    def should_be(diff, keyword, key, value)
        hash = diff.send(keyword)
        if hash[key] != value
            puts "#{key} should be '#{value}'"
            @found = true
        end
    end
    
    def should_be_same(keyword, key)
        issue = false
        last = nil
        @diffs.each { |diff|
            hash = diff.send(keyword)
            unless last == nil
                issue = true unless last == hash[key]
            end
            last = hash[key]
        }
        
        if issue
            @found = true
            
            puts "#{key} should be the same in all diffs!"
            @diffs.each { |diff|
                hash = diff.send(keyword)
                puts "In '#{diff.diff}' it's '#{hash[key]}'"
            }
            empty()
        end
    end
    
private
    def analyze_dir(files, dir, excludes)
        files = (Dir.entries(dir) - excludes).map { |c| "#{dir}\\#{c}" }

        files.each { |file|
            if File.directory? file
                analyze_dir(@files, file, excludes)
            else
                @files << file.gsub("#{@directory}\\", '')
            end
        }
    end # analyze_dir
    
# HELPERS

    def no_issues_found?()
        puts "No issues found" unless @found
        @found = false
    end # no_issues_found?
    
    def empty()
        puts()
    end # empty

# END HELPERS
end # Comparer

comparer = Comparer.new(*ARGV)