$remove_hs = ARGV[0]
$from = ARGV[1] + ".osu"
$to = ARGV[2] + ".osu"

file = File.open($from, "rb")
@input = file.read().gsub(/\r\n?/, "\n")
file.close

@events = []

@start = false
@input.each_line { |line| 
    unless @start
        @start = line.start_with?("[HitObjects]")
    else
        l = {}
        data = line.split(",")
        
        l[:row] = data[0]
        l[:time] = data[2]
        l[:hs] = data[4]
        lastblock = data[5]
        
        sdat = lastblock.split(":")
        l[:ln] = sdat.size == 6
        sdat.shift() if l[:ln]
            
        l[:hstype], l[:adtype], l[:setid], l[:volume], l[:fname] = sdat
        l[:hsed] = sdat != ["0", "0", "0", "0", "\n"]
        l[:hsed] = true if data[4] != "0"
        
        @events << l
    end
}

file = File.open($to, "rb")
@output = file.read().gsub(/\r\n?/, "\n")
file.close

@outevents = []
@start = false
@index = 0
@output.each_line { |line| 
    unless @start
        @start = line.start_with?("[HitObjects]")
        @index += 1
    else
        l = {:hstype => 0, :adtype => 0, :setid => 0, :volume => 0, :fname => "\n", :hs => 0, :line => line}
        
        data = line.split(",")
        
        l[:row] = data[0]
        l[:time] = data[2]
        
        lastblock = data[5]
        sdat = lastblock.split(":")
        l[:ln] = sdat.size == 6
        
        if $remove_hs == "0"
            l[:hs] = data[4]
            
            sdat.shift() if l[:ln]
            l[:hstype], l[:adtype], l[:setid], l[:volume], l[:fname] = sdat
        end
        
        @outevents << l
    end
}

@nothingfoundfor = []
@outevents.each_index { |i| 
    @outevents[i][:index] = i
    @outevents[i][:mod] = false
}

@modtimes = {}

@events.select() do |e| e[:hsed] end.each { |event|
    # find out which outevents has same start time
    objects = @outevents.select { |e| e[:time] == event[:time] }
    
    # try to find object with same row
    rowobjects = objects.select { |e| e[:row] == event[:row] }
    if rowobjects.empty?
        rowobjects = objects.select { |e| e[:mod] == false }
    end
    if rowobjects.empty?
        @nothingfoundfor << event
    else
        editevent = rowobjects[0]
        editevent[:mod] = true
        
        editevent[:hs] = event[:hs]
        
        editevent[:hstype] = event[:hstype]
        editevent[:adtype] = event[:adtype]
        editevent[:setid] = event[:setid]
        editevent[:volume] = event[:volume]
        editevent[:fname] = event[:fname]
        
        @outevents[editevent[:index]] = editevent
        
        @modtimes[editevent[:time].to_sym] = @modtimes[editevent[:time].to_sym].nil? ? 1 : @modtimes[editevent[:time].to_sym] + 1
    end
}

# find events, which has a timemark as a modified event in input and was not modified in output.
# Find only if this row has more elements than in input diff

@different_objectcount = []
@modtimes.each { |e| 
    time = e[0].to_s
    modified = e[1]
    
    # elements in original
    original = @events.select() { |o| o[:time] == time }
    # elements in new diff
    target = @outevents.select() { |o| o[:time] == time }
    unless original.size == target.size
        @different_objectcount << {:time => time, :orig => original.size, :target => target.size }
    end
}

# Modify Lines
@outevents.select() do |e| e[:mod] end.each { |e|
    if e[:ln]
        e[:line].gsub!(/(\d+),(\d+),(\d+),(\d+),\d+,(\d+):\d+:\d+:\d+:\d+:.*/) {
            "#{$1},#{$2},#{$3},#{$4},#{e[:hs]},#{$5},#{e[:hstype]}:#{e[:adtype]}:#{e[:setid]}:#{e[:volume]}:#{e[:fname]}"
        }
    else
        e[:line].gsub!(/(\d+),(\d+),(\d+),(\d+),\d+,\d+:\d+:\d+:\d+:.*/) {
            "#{$1},#{$2},#{$3},#{$4},#{e[:hs]},#{e[:hstype]}:#{e[:adtype]}:#{e[:setid]}:#{e[:volume]}:#{e[:fname]}"
        }
    end
    
    @outevents[e[:index]] = e
}
file = File.open($to + ".new", "wb")

@start = false
@index = 0
@output.each_line { |line| 
    unless @start
        @start = line.start_with?("[HitObjects]")
        @index += 1
        
        file.puts(line)
    else
        break
    end
}

@outevents.each { |e| file.puts(e[:line].gsub(/\n/, "")) }
file.close()

print("Objects, where no target could find:\n")
@nothingfoundfor.each { |e| p e }
print("Count: ", @nothingfoundfor.size, "\n\n")

print("Timestamps you should check manually:\n")
@different_objectcount.each { |e| p e }
print("Count: ", @different_objectcount.size, "\n\n")

print("Total Hitobjects modified:\n", @outevents.select() do |e| e[:mod] end.size, "\n\n")