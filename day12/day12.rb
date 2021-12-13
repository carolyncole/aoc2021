require 'byebug'
data = File.readlines('day12.txt').map(&:chomp)

class Value
  attr_accessor :map, :location, :exits, :traversed, :large_cave, :end_of_cave

  def initialize(map, location)
    @map = map
    @location =  location
    @exits = []
    @traversed = false
    @large_cave = (location == location.upcase)
    @end_of_cave = location == "end"
  end

  def traverse(routes, current_route)
    return if end_traverse?(current_route)
    current_route << location
    if end_of_cave
      routes << current_route
    else
      exits.each do |exit| 
        new_route = current_route.clone
        map.traverse(location: exit, routes: routes, current_route: new_route)        
      end
    end
  end

  def end_traverse?(current_route)
    return false if large_cave
    return false if !current_route.include?(location)
    small_locations = (current_route -["start"] -["end"]).reject{|location| location == location.upcase }
    tallies = small_locations.tally
    tallies.size != tallies.values.sum
  end

  def add_exit(exit)
    exits << exit
  end

  def to_s
    "#{@value} #{exits.join(',')}"
  end
end

class CaveMap
  attr_accessor :map

  def initialize(input_data)
    @map = {}
    @map["end"] = Value.new(self, "end")
    input_data.each do |segment|
      start, exit = segment.split('-')
      if (exit != "start") && (start != "end")
        @map[start] ||= Value.new(self, start)
        @map[start].add_exit(exit)
      end
      if (start != "start")
        @map[exit] ||= Value.new(self, exit)
        @map[exit].add_exit(start)
      end
    end
  end


  def traverse(location: "start", routes: [], current_route: [])
    byebug if map[location].nil? 
    map[location].traverse(routes,current_route)
    routes
  end

  def to_s
    map.each{|key, value| puts "#{key} #{value}" }
  end
end

cave_map = CaveMap.new(data)

puts cave_map

routes = cave_map.traverse
# routes.each {|route| puts route.join(",")}
puts routes.count


# start,A,b,A,c,A,end
# start,A,b,A,end
# start,A,b,end
# start,A,c,A,b,A,end
# start,A,c,A,b,end
# start,A,c,A,end
# start,A,end
# start,b,A,c,A,end
# start,b,A,end
# start,b,end

# start,A,b,A,c,A,end
# start,A,b,A,end
# start,A,b,end
# start,A,c,A,b,A,end
# start,A,c,A,b,end
# start,A,c,A,end
# start,A,end
# start,b,A,c,A,end
# start,b,A,end
# start,b,end
