require 'byebug'
data = File.readlines('day5.txt').map(&:chomp)

class Value
  attr_accessor :passes
  def initialize()
    @passes = 0
  end

  def pass
    @passes+=1
  end

  def dangerous?
    @passes >= 2
  end

  def to_s
    "#{passes} #{dangerous?}"
  end
end

class DangerMap
  attr_accessor :rows

  def initialize(max_x, max_y)
    @rows = (0..max_y).map{|row| (0..max_x).map {Value.new}}
  end

  def pass(start_x, start_y, end_x, end_y)
    puts start_x, start_y, end_x, end_y 
    if start_y == end_y
      horizontal_pass(start_y, start_x, end_x) 
    elsif start_x == end_x
      vertical_pass(start_x, start_y, end_y) 
    elsif (end_x-start_x).abs == (end_y-start_y).abs
      diagonal_pass(start_x, end_x, start_y, end_y)
    end
  end

  def horizontal_pass(y, start_x, end_x)
    (start_x..end_x).each{|x| rows[y][x].pass }
  end

  def vertical_pass(x, start_y, end_y)
    (start_y..end_y).each{|y| rows[y][x].pass }
  end

  def diagonal_pass(start_x, end_x, start_y, end_y)
    slope_x = (end_x-start_x)/(end_y-start_y).abs
    slope_y = (end_x-start_x).abs/(end_y-start_y)
    (0..(end_y-start_y).abs).each{|idx| rows[start_y+(idx*slope_y)][start_x+(idx*slope_x)].pass }
  end

  def dangerous_count
    rows.sum{|row| row.count(&:dangerous?)}
  end

  def to_s
    @rows.each{|row| puts row.map(&:to_s).join(" ")}
  end
end

lines = data.map do |data_line|
          # 0,9 -> 5,9
          start_point, end_point = data_line.split(' -> ').map{|point_str| point_str.split(',').map(&:to_i)}
          if start_point[0] >  end_point[0] || start_point[1] >  end_point[1]
            sav = end_point
            end_point = start_point
            start_point = sav
          end
          {start_point: start_point, end_point: end_point}
        end
max_x = lines.max { |a, b| a[:end_point][0] <=> b[:end_point][0] }[:end_point][0]
max_y = lines.max { |a, b| a[:end_point][1] <=> b[:end_point][1] }[:end_point][1]

danger_map = DangerMap.new(max_x, max_y)

lines.each do |line| 
  danger_map.pass(line[:start_point][0], line[:start_point][1], line[:end_point][0], line[:end_point][1])
end

puts danger_map

puts "Dangerous count #{danger_map.dangerous_count}"

