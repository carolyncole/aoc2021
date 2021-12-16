require 'byebug'
data = File.readlines('day15.txt').map(&:chomp)

class Value
  attr_accessor :cave_map, :x, :y, :exits, :traversed, :value

  def initialize(cave_map, x,y, value)
    @cave_map = cave_map
    @x =  x
    @y = y
    @value = value
    @exits = []
    @traversed = false
  end

  def traverse(total)
    return if total >  cave_map.current_minimum_route
    total+= self.value
    if i_am_exit?
      current_sum = total
      if current_sum <  cave_map.current_minimum_route
        puts "Got better total #{current_sum}"
        cave_map.current_minimum_route = current_sum 
      end
      return 
    end

    new_locations = []
    new_locations << cave_map.location(x+1,y) if x < cave_map.max_x
    new_locations << cave_map.location(x,y+1) if y < cave_map.max_y
    new_locations.sort_by(&:value).each {|location| location.traverse(total.clone)}
  end

  def i_am_exit?
    @i_am_exit ||= ((x == cave_map.max_x) && (y == cave_map.max_y))
  end

  def output
    puts "#{@value} #{x},#{y}"
  end

  def to_s
    if i_am_exit?
      "#{@value} *"
    else
      "#{@value}"
    end
  end
end

class CaveMap
  attr_accessor :rows, :max_x, :max_y, :current_minimum_route
  
  def initialize(input_data)    
    @rows = input_data.each_with_index.map{|row, y| row.split("").each_with_index.map {|value, x| Value.new(self,x,y, value.to_i)}}
    @max_x = rows.first.length-1
    @max_y = rows.length-1
  end

  def traverse
    min_route = (0..max_x).map{|x| rows[0][x]}
    (1..max_y).each {|y| min_route << rows[y][max_x]}
    @current_minimum_route = min_route.sum(&:value)
    rows[0][0].traverse(0)
  end

  def location(x,y)
    rows[y][x]
  end

  def to_s
    rows.map{|row| row.map(&:to_s).join(" ")}.join("\n")
  end
end

# cave_map = CaveMap.new(data)
# routes = cave_map.traverse
# min_route =  routes.min {|route1, route2| route1.sum(&:value) <=> route2.sum(&:value) }
# puts min_route.sum(&:value) - min_route[0].value

# cave_map.traverse

# puts (cave_map.current_minimum_route - cave_map.location(0,0).value)

### All code above this line was my cute attempt to brute force the answer ###

data_grid = data.map{|row| row.split("").map(&:to_i)}
max_row = data.length-1
max_col = data.first.length-1
new_grid = []
5.times do |row_multiplier|
  5.times do |col_multiplier|
    data_grid.each_with_index do |row, row_idx| 
                  new_grid << [] if col_multiplier == 0
                  row.each_with_index do |value, col_idx|
                    new_value = row_multiplier+col_multiplier+value
                    new_value = new_value % 9 if new_value > 9
                    new_grid[(max_row+1)*row_multiplier+row_idx][(max_col+1)*col_multiplier+col_idx] = new_value
                 end
               end
  end
end

puts new_grid.map{|row| row.join("")}.join("\n")

# Dijkstra code is care of the internet.  Thank you google and tsmsogn !!!
# https://gist.github.com/tsmsogn/ae5e5d76fb04226edf98
# Code between here and the matching comment below was copy pasted!!!!
# Node
class Node
  attr_accessor :id, :edges, :cost, :done

  def initialize(id, edges = [], cost = nil, done = false)
    @id, @edges, @cost, @done = id, edges, cost, done
  end
end

# Edge
class Edge
  attr_accessor :to, :cost

  def initialize(to, cost)
    @to, @cost = to, cost
  end
end

# Dijkstra
class Dijkstra
  attr_accessor :nodes

  def initialize(data)
    @nodes = {}
    data.each do |id, edges|
      edges.map! { |edge| Edge.new(*edge) }
      @nodes[id] = Node.new(id, edges)
    end
  end

  def start(start_id)
    @nodes.each do |id, node|
      node.done = false
      node.cost = node.id == start_id ? 0 : -1
    end

    queue = [@nodes[start_id]]

    until queue.empty?
      queue.sort! { |l, r| r.cost <=> l.cost }
      done_node = queue.pop
      done_node.done = true
      done_node.edges.each do |edge|
        node = @nodes[edge.to]
        cost = done_node.cost + edge.cost
        if node.cost < 0 || cost < node.cost
          node.cost = cost
          queue << node unless queue.include?(node)
        end
      end
    end
  end
end
# Dijkstra code is care of the internet
# https://gist.github.com/tsmsogn/ae5e5d76fb04226edf98
# Code between the above comments here was copy pasted!!!!

edges = {}
max_row = new_grid.length-1
max_col = new_grid.first.length-1
(0..(max_row)).each do |row_idx|
  (0..(max_col)).each do |col_idx|
    current =  [row_idx, col_idx]
    edges[current] = []
    edges[current] << [[row_idx+1, col_idx], new_grid[row_idx+1][col_idx]] if row_idx < max_row
    edges[current] << [[row_idx, col_idx+1], new_grid[row_idx][col_idx+1]] if col_idx < max_col
    edges[current] << [[row_idx-1, col_idx], new_grid[row_idx-1][col_idx]] if row_idx > 0
    edges[current] << [[row_idx, col_idx-1], new_grid[row_idx][col_idx-1]] if col_idx > 0
  end
end

dijkstra = Dijkstra.new(edges)
dijkstra.start [0,0]
puts dijkstra.nodes[[max_col,max_row]].cost
