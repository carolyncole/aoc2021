require 'byebug'
data = File.readlines('day9.txt').map(&:chomp)

class Value
  attr_accessor :map, :map_height, :map_width, :location_x, :location_y, :value, :part_of_basin

  def initialize(map, value, location_x, location_y)
    @map = map
    @value =  value
    @location_x = location_x
    @location_y = location_y
    @part_of_basin = value == 9
  end

  def low_top?
    return true if location_y == 0
    value < map.value(location_x,location_y-1)
  end

  def low_bottom?
    return true if location_y == map.height-1
    value < map.value(location_x,location_y+1)
  end

  def low_left?
    return true if location_x == 0
    value < map.value(location_x-1,location_y)
  end

  def low_right?
    return true if location_x == map.width-1
    value < map.value(location_x+1,location_y)
  end

  def low?
    @low ||= low_left? && low_right? && low_top? && low_bottom?
  end

  def risk_level
    return 0 unless low?
    1+value
  end

  def to_s
    "#{value} #{location_x},#{location_y} #{low?}"
  end
end

class DangerMap
  attr_accessor :map, :height, :width, :low_points, :basins

  def initialize(input_data)
    @map = []
    input_data.each_with_index do |row, y|
      map_row = []
      row.split("").each_with_index{ |value, x| map_row << Value.new(self, value.to_i, x, y)}
      map << map_row
    end

    @height = map.length
    @width = map.first.length
    @low_points = @map.map{|row| row.select(&:low?)}.flatten
    @basins = @low_points.map{|low_point| calculate_basin(low_point) }

  end

  def dangerous_count
    map.sum{|row| row.count(&:low?)}
  end

  def risk_level
    map.sum{|row| row.sum(&:risk_level)}
  end

  def calculate_basin(low_point, basin = [])
    return basin if low_point.part_of_basin
    basin << low_point
    low_point.part_of_basin = true
    calculate_basin(map[low_point.location_y][low_point.location_x-1], basin) if low_point.location_x > 0
    calculate_basin(map[low_point.location_y][low_point.location_x+1], basin) if low_point.location_x < width-1
    calculate_basin(map[low_point.location_y-1][low_point.location_x], basin) if low_point.location_y > 0
    calculate_basin(map[low_point.location_y+1][low_point.location_x], basin) if low_point.location_y < height-1
    basin
  end

  def value(x,y)
    map[y][x].value
  end

  def to_s
    map.each{|row| puts row.map(&:to_s).join(" ")}
  end
end

danger_map = DangerMap.new(data)

puts danger_map

puts "Dangerous count #{danger_map.dangerous_count}"
puts "Risk level #{danger_map.risk_level}"

# puts danger_map.basins
sizes =  danger_map.basins.map(&:count).sort
puts sizes

puts sizes[sizes.length-1] * sizes[sizes.length-2] * sizes[sizes.length-3]
