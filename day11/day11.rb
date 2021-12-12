require 'byebug'
data = File.readlines('day11.txt').map(&:chomp)

class Value
  attr_accessor :map, :location_x, :location_y, :value, :flashed

  def initialize(map, value, location_x, location_y)
    @map = map
    @value =  value
    @location_x = location_x
    @location_y = location_y
    @flashed = false
  end

  def give_power
    @value+=1
  end

  def ready_to_flash?
    !@flashed && @value > 9
  end

  def reset_flashed
    return unless @flashed
    @value = 0
    @flashed = false
  end

  def flash
    return unless ready_to_flash?
    @flashed = true
    # above
    if (location_y > 0)
      map.value(location_x-1,location_y-1).give_power() if (location_x > 0) 
      map.value(location_x, location_y-1).give_power()
      map.value(location_x+1, location_y-1).give_power() if (location_x < (map.width-1))
    end

    # same row
    map.value(location_x-1, location_y).give_power() if location_x > 0
    map.value(location_x+1, location_y).give_power() if location_x < map.width-1

    #below
    if (location_y < (map.height-1))
      map.value(location_x-1, location_y+1).give_power() if location_x > 0
      map.value(location_x, location_y+1).give_power() 
      map.value(location_x+1, location_y+1).give_power() if (location_x < (map.width-1))
    end
  end

  def to_s
    @value
  end
end

class FlashMap
  attr_accessor :map, :height, :width, :total_flashes, :all_on

  def initialize(input_data)
    @map = []
    input_data.each_with_index do |row, y|
      map_row = []
      row.split("").each_with_index{ |value, x| map_row << Value.new(self, value.to_i, x, y)}
      map << map_row
    end

    @height = map.length
    @width = map.first.length
    @total_flashes = 0
    @all_on = nil
  end


  def any_ready_to_flash?
    map.reduce(false) do |memo, row| 
      memo || row.reduce(false){|row_memo, value| row_memo || value.ready_to_flash? }
    end
  end

  def step(idx)
    map.each{|row| row.each{|value| value.give_power}}
    while(any_ready_to_flash?) do
      map.each{|row| row.each{|value| value.flash}}
    end
    octo_flashes = map.sum{|row| row.select(&:flashed).size }
    @all_on ||= idx if octo_flashes == height * width
    @total_flashes += octo_flashes
    map.each{|row| row.each{|value| value.reset_flashed }}
  end

  def value(x,y)
    map[y][x]
  end

  def to_s
    map.each{|row| puts row.map(&:to_s).join(" ")}
  end
end

flash_map = FlashMap.new(data)

# puts flash_map

# 100.times do |idx|
#   flash_map.step(idx)
#   puts flash_map
# end

# puts flash_map.total_flashes


100000000.times do |idx|
  flash_map.step(idx)
  break if flash_map.all_on
end
puts flash_map.all_on+1