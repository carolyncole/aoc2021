require 'byebug'
data = File.readlines('day20.txt').map(&:chomp)

class Point
  attr_accessor :lighted

  def initialize(lighted_str)
   @lighted = lighted_str == "#"
  end

  def to_s
    if @lighted
      "1"
    else
      "0"
    end
  end

  def to_i
    if @lighted
      1
    else
      0
    end
  end
end

class Filter
  attr_accessor :filter_map
  
  def initialize(input_data)
    @filter_map = input_data.split("").map{|str| Point.new(str)}
  end

  def to_s
    filter_map.join("")
  end
end

class Image
  attr_accessor :image_data
  
  def initialize(input_data)
    puts input_data[0]
    @image_data = input_data.map{|row| row.split("").map{|str| Point.new(str)}}
    @last_mat = false
    grow_image
  end


  def run_filter(filter)
    grow_image
    new_map = []
    image_data.each_with_index do |row, y|
      new_map[y] ||= []
      image_data.each_with_index do |point, x|
        filter_index = build_filter_index(x, y)
        idx = filter_index.to_i(2)
        point = filter.filter_map[idx]
        new_map[y][x] = point
      end
    end
    @image_data  = new_map
    @last_mat = !@last_mat
  end

  def grow_image
    new_image = []

    new_image << empty_row
    @image_data.each do | row|
      new_image << [Point.new(current_mat)]+row+[Point.new(current_mat)]
    end
    new_image << empty_row
    @image_data = new_image
  end

  def build_filter_index(x,y)
    row1 = if y == 0
             "000"
           else
            build_filter_row(y-1, x)
           end
    row2 = build_filter_row(y, x)
    row3 = if y == (image_data.length-1)
             "000"
           else
            build_filter_row(y+1, x)
           end
    row1+row2+row3
  end

  def build_filter_row(y, x)
    if x == 0
      current_fill+image_data[y][x..x+1].join("")
    elsif x == (image_data[y].length-1)
      image_data[y][x-1..x].join("")+current_fill
    else
      image_data[y][x-1..x+1].join("")
    end
  end

  def empty_row
    (image_data.first.length+1).times.map {Point.new(current_mat)}
  end

  def total_lit
    image_data.sum{|row|row.map(&:to_i).sum -row.last.to_i }
  end

  def current_fill
    if @last_mat
      "1"
    else
      "0"
    end
  end

  def current_mat
    if @last_mat
      "#"
    else
      "."
    end
  end

  def to_s
    image_data.map{|row| row.join("")}.join("\n")
  end
end

filter = Filter.new(data.first)
image = Image.new(data[2..])

puts filter
puts image

2.times { image.run_filter(filter)}

puts image
puts image.total_lit
puts filter.filter_map.length