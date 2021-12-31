require 'byebug'
data = File.readlines('day22.txt').map(&:chomp)

class Point
  include Comparable

  attr_accessor :x, :y, :z
  
  def initialize(x,y,z)
    @x = x
    @y = y
    @z = z
  end

  def ==(another_point)
    self.x == another_point.x && self.y == another_point.y && self.z == another_point.z
  end

  def <=>(another_point)
    self.x <=> another_point.x && self.y <=> another_point.y && self.z <=> another_point.z
  end

  def to_s
    "(#{x},#{y},#{z})"
  end
end

class Plane
  attr_accessor :start_point, :end_point, :value
  def initialize(start_point, end_point, value)
    raise "Plane is 2d" if start_point.z != end_point.z
    @start_point = start_point
    @end_point = end_point
    @value = value
  end 

  def ==(another)
    start_point == another.start_point && end_point == another.end_point
  end

  def <=>(another_point)
    start_point <=> another_point.start_point && end_point <=> another_point.end_point
  end


  def include?(plane)
    return false if (plane.start_point.z != start_point.z)
    return false if ((plane.end_point.y < start_point.y) || (plane.start_point.y > end_point.y))
    return false if ((plane.end_point.x < start_point.x) || (plane.start_point.x > end_point.x))
    (((plane.end_point.y >= start_point.y) && (plane.start_point.y <= end_point.y)) && 
      ((plane.end_point.x >= start_point.x) && (plane.start_point.x <= end_point.x))) 
  end

  def subtract(plane)
    return [self] if plane.start_point.z != start_point.z
    return [] if plane.start_point.x <= start_point.x && plane.end_point.x >= end_point.x &&
                    plane.start_point.y <= start_point.y && plane.end_point.y >= end_point.y
    return [self] if plane.end_point.x < start_point.x ||  plane.start_point.x > end_point.x ||
                           plane.end_point.y < start_point.y ||  plane.start_point.y > end_point.y

    new_planes = []
    if plane.start_point.x > start_point.x && plane.end_point.x < end_point.x

      # interior plane x
      if plane.start_point.y > start_point.y && plane.end_point.y < end_point.y
        # interior plane
        new_planes << top_plane(plane)
        new_planes << bottom_plane(plane)
        new_planes << left_plane(plane)
        new_planes << right_plane(plane)
      elsif plane.start_point.y <= start_point.y && plane.end_point.y >= end_point.y
        # slice through the middle fully
        new_planes << left_plane(plane)
        new_planes << right_plane(plane)
      elsif plane.start_point.y <= start_point.y && plane.end_point.y < end_point.y          
        # middle plane from the top
        new_planes << bottom_plane(plane)
        new_planes << left_plane(plane)
        new_planes << right_plane(plane)
      elsif plane.start_point.y >= start_point.y && plane.end_point.y >= end_point.y          
        # middle plane from the top
        new_planes << top_plane(plane)
        new_planes << left_plane(plane)
        new_planes << right_plane(plane)
      else
        byebug
      end
    elsif plane.start_point.x <= start_point.x && plane.end_point.x < end_point.x
      # left side
      if plane.start_point.y <= start_point.y && plane.end_point.y < end_point.y
        # slice the top corner
        new_planes << bottom_plane(plane)
        new_planes << right_plane(plane)
      elsif plane.start_point.y > start_point.y && plane.end_point.y >= end_point.y
        # slice the bottom corner
        new_planes << top_plane(plane)
        new_planes << right_plane(plane)
      elsif plane.start_point.y <= start_point.y && plane.end_point.y >= end_point.y
        new_planes << right_plane(plane)
      else
        new_planes << top_plane(plane)
        new_planes << bottom_plane(plane)
        new_planes << right_plane(plane)
      end
    elsif plane.start_point.x > start_point.x && plane.end_point.x >= end_point.x
      # right side
      if plane.start_point.y <= start_point.y && plane.end_point.y < end_point.y
        # slice the top corner
        new_planes << bottom_plane(plane)
        new_planes << left_plane(plane)
      elsif plane.start_point.y > start_point.y && plane.end_point.y >= end_point.y
        # slice the bottom corner
        new_planes << top_plane(plane)
        new_planes << left_plane(plane)
      elsif plane.start_point.y <= start_point.y && plane.end_point.y >= end_point.y
        new_planes << left_plane(plane)
      else
        new_planes << top_plane(plane)
        new_planes << bottom_plane(plane)
        new_planes << left_plane(plane)
      end
    else # all of x
      if plane.start_point.y <= start_point.y && plane.end_point.y < end_point.y
        # slice the bottom
        new_planes << bottom_plane(plane)
      elsif plane.start_point.y > start_point.y && plane.end_point.y >= end_point.y
        # slice the top
        new_planes << top_plane(plane)
      else
        new_planes << bottom_plane(plane)
        new_planes << top_plane(plane)
      end
    end
    new_planes
  end

  def top_plane(plane)
    Plane.new(start_point, Point.new(end_point.x,plane.start_point.y-1, start_point.z), value)
  end

  def bottom_plane(plane)
    Plane.new(Point.new(start_point.x,plane.end_point.y+1,start_point.z), end_point, value)
  end

  def left_plane(plane)
    start_y = [plane.start_point.y,start_point.y].max
    end_y = [plane.end_point.y,end_point.y].min
    Plane.new(Point.new(start_point.x,start_y,start_point.z), Point.new(plane.start_point.x-1,end_y,start_point.z), value)
  end

  def right_plane(plane)
    start_y = [plane.start_point.y,start_point.y].max
    end_y = [plane.end_point.y,end_point.y].min
    Plane.new(Point.new(plane.end_point.x+1,start_y,start_point.z),Point.new(end_point.x,end_y,start_point.z), value)
  end

  def add(plane)
    return [self] if plane.start_point.z != start_point.z
    return [plane] if plane.start_point.x <= start_point.x && plane.end_point.x >= end_point.x &&
                    plane.start_point.y <= start_point.y && plane.end_point.y >= end_point.y
    return [self,plane] if plane.end_point.x < start_point.x ||  plane.start_point.x > end_point.x ||
                           plane.end_point.y < start_point.y ||  plane.start_point.y > end_point.y

    new_planes = plane.subtract(self)
    new_planes << self
    new_planes
  end

  def covers
    (end_point.x - start_point.x + 1)*(end_point.y-start_point.y+1)
  end

  def to_s
    "#{start_point}..#{end_point} #{value}"
  end

end

class Line
  attr_accessor :start_point, :end_point, :value

  def initialize(start_point, end_point, value)
    raise "Line is 1d" if start_point.z != end_point.z && start_point.y != end_point.y
    @start_point = start_point
    @end_point = end_point
    @value = value
  end

  def include?(line)
    return false if line.start_point.z != start_point.z || line.start_point.y != start_point.y
    start_point.x <= line.start_point.x && line.end_point.x <= end_point.x ||
    line.start_point.x <= end_point.x && line.end_point.x >= end_point.x ||
    line.start_point.x <= start_point.x && line.end_point.x >= start_point.x
  end

  def subtract(line)
    return self if line.start_point.z != start_point.z || line.start_point.y != start_point.y
    if line.start_point.x > start_point.x
      start_point.x = line.start_point.x+1
    end
    if line.end_point.x < end_point.x
      end_point.x = line.end_point.x-1
    end
    self
  end

  def add(line)
    return self if line.start_point.z != start_point.z || line.start_point.y != start_point.y
    if line.start_point.x < start_point.x
      start_point.x = line.start_point.x
    end
    if line.end_point.x > end_point.x
      end_point.x = line.end_point.x
    end
    self
  end

  def covers
    end_point.x - start_point.x + 1
  end

  def to_s
    "#{start_point}..#{end_point} #{value}"
  end
end

class Range
  attr_accessor :start_point, :end_point, :value, :grid

  def self.parse(range_str)
    # on x=-20..26,y=-36..17,z=-47..7
    on_off, xyz_str = range_str.split(" ")
    value = on_off == "on"
    x_str, y_str, z_str = xyz_str.split(",")
    x_start, x_end = x_str[2..].split('..').map(&:to_i).sort
    y_start, y_end = y_str[2..].split('..').map(&:to_i).sort
    z_start, z_end = z_str[2..].split('..').map(&:to_i).sort
    start_point = Point.new(x_start,y_start,z_start)
    end_point = Point.new(x_end,y_end,z_end)
    Range.new(start_point,end_point,value)
  end

  def initialize(start_point, end_point, value)
    @start_point = start_point
    @end_point = end_point
    @value = value
    @grid = (start_point.z..end_point.z).map do |z| 
              Plane.new(Point.new(start_point.x,start_point.y,z), Point.new(end_point.x,end_point.y,z), value)
            end
  end

  def to_s
    "#{start_point}..#{end_point} #{value}"
  end
end

class Reactor
  attr_accessor :lit_planes

  def initialize
    @lit_planes = []
  end

  def merge_pane(plane)
    return if lit_planes.include?(plane)
    planes_to_change = lit_planes.select{|lit_plane| lit_plane.include?(plane)}
    lit_planes << plane 
    if planes_to_change.count > 0
      planes_to_change.each do |lit_plane|
        new_planes = lit_plane.subtract(plane)
        if (new_planes.include?(lit_plane))
          new_planes.delete(lit_plane)
        else
          lit_planes.delete(lit_plane)
        end
        @lit_planes = lit_planes + new_planes
      end
    end
  end

  def process_plane(plane)
    planes_to_change = lit_planes.select{|lit_plane| lit_plane.include?(plane)}
    lit_planes << plane if planes_to_change.count == 0 && plane.value
    if plane.value
      merge_pane(plane)
    else
      planes_to_change.each do |lit_plane|
        new_planes = lit_plane.subtract(plane)
        if (new_planes.include?(lit_plane))
          new_planes.delete(lit_plane)
        else
          lit_planes.delete(lit_plane)
        end
        @lit_planes = lit_planes + new_planes
      end
    end
  end

  def process(range)
    range.grid.flatten.each do |plane|
      process_plane(plane)
    end
  end

  def to_i
    lit_planes.sum{|plane| plane.covers }
  end

  def to_s
    lit_planes.join("\n")
  end
end


target_plane = Plane.new(Point.new(10,10,10),Point.new(20,20,10),true)
remove_plane1 = Plane.new(Point.new(13,13,10),Point.new(15,15,10),true)
new_planes = target_plane.subtract(remove_plane1)
puts (target_plane.covers - remove_plane1.covers) == new_planes.sum{|plane| plane.covers }
remove_plane2 = Plane.new(Point.new(13,10,10),Point.new(15,20,10),true)
new_planes = target_plane.subtract(remove_plane2)
puts (target_plane.covers - remove_plane2.covers) == new_planes.sum{|plane| plane.covers }
remove_plane3 = Plane.new(Point.new(13,10,10),Point.new(15,15,10),true)
new_planes = target_plane.subtract(remove_plane3)
puts (target_plane.covers - remove_plane3.covers) == new_planes.sum{|plane| plane.covers }
remove_plane4 = Plane.new(Point.new(13,15,10),Point.new(15,20,10),true)
new_planes = target_plane.subtract(remove_plane4)
puts (target_plane.covers - remove_plane4.covers) == new_planes.sum{|plane| plane.covers }
remove_plane5 = Plane.new(Point.new(10,13,10),Point.new(10,15,10),true)
new_planes = target_plane.subtract(remove_plane5)
puts (target_plane.covers - remove_plane5.covers) == new_planes.sum{|plane| plane.covers }
remove_plane6 = Plane.new(Point.new(10,10,10),Point.new(10,15,10),true)
new_planes = target_plane.subtract(remove_plane6)
puts (target_plane.covers - remove_plane6.covers) == new_planes.sum{|plane| plane.covers }
remove_plane = Plane.new(Point.new(10,15,10),Point.new(10,20,10),true)
new_planes = target_plane.subtract(remove_plane)
puts (target_plane.covers - remove_plane.covers) == new_planes.sum{|plane| plane.covers }
remove_plane = Plane.new(Point.new(15,13,10),Point.new(20,15,10),true)
new_planes = target_plane.subtract(remove_plane)
puts (target_plane.covers - remove_plane.covers) == new_planes.sum{|plane| plane.covers }
remove_plane = Plane.new(Point.new(15,10,10),Point.new(20,15,10),true)
new_planes = target_plane.subtract(remove_plane)
puts (target_plane.covers - remove_plane.covers) == new_planes.sum{|plane| plane.covers }
remove_plane = Plane.new(Point.new(15,15,10),Point.new(20,20,10),true)
new_planes = target_plane.subtract(remove_plane)
puts (target_plane.covers - remove_plane.covers) == new_planes.sum{|plane| plane.covers }
remove_plane = Plane.new(Point.new(10,15,10),Point.new(20,20,10),true)
new_planes = target_plane.subtract(remove_plane)
puts (target_plane.covers - remove_plane.covers) == new_planes.sum{|plane| plane.covers }
remove_plane = Plane.new(Point.new(10,10,10),Point.new(20,15,10),true)
new_planes = target_plane.subtract(remove_plane)
puts (target_plane.covers - remove_plane.covers) == new_planes.sum{|plane| plane.covers }


lower_bound = Point.new(-50,-50,-50)
upper_bound = Point.new(50,50,50)
reactor = Reactor.new
data.each do |range_str|
  range = Range.parse(range_str)
  # if range.start_point >= lower_bound && range.start_point <= upper_bound
    reactor.process(range)
  # end
  # puts reactor.to_s
  # puts reactor.to_i
end
byebug
puts reactor.to_i
