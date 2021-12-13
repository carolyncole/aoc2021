require 'byebug'
data = File.readlines('day13.txt').map(&:chomp)

class Value
  attr_accessor :on, :x, :y, :paper
  def initialize(paper, x, y)
    @x = x
    @y = y
    @on = false
    @paper = paper
  end

  def mark
    @on = true
  end

  def on?
    @on
  end

  def fold_up(fold_pos)
    return if y < fold_pos || !on?
    new_y = fold_pos - (y-fold_pos)
    paper.mark(x,new_y) if new_y >= 0
  end


  def fold_left(fold_pos)
    return if x < fold_pos || !on?
    new_x = fold_pos - (x-fold_pos)
    paper.mark(new_x,y) if new_x >= 0
  end

  def to_s
    on? ? "#" : "."
  end
end

class InstructionPaper
  attr_accessor :rows, :max_x, :max_y

  def initialize(max_x, max_y)
    @rows = (0..max_y).map{|y| (0..max_x).map {|x| Value.new(self,x,y)}}
    @max_x = max_x
    @max_y = max_y
  end

  def mark(x,y)
    rows[y][x].mark
  end

  def fold(fold)
    values = fold.split(" ")[2]
    line, fold_position = values.split("=")
    if line == 'x'
      fold_left(fold_position.to_i)
    else
      fold_up(fold_position.to_i)
    end
  end

  def fold_up(fold_position)
    (0..max_y).each do |y|
      (0..max_x).each do |x|
        rows[y][x].fold_up(fold_position)
      end
    end
    @max_y = fold_position - 1
  end

  def fold_left(fold_position)
    (0..max_y).each do |y|
      (0..max_x).each do |x|
        rows[y][x].fold_left(fold_position)
      end
    end
    @max_x = fold_position -1
  end

  def number_on
    @rows.take(max_y+1).sum{|row| row.take(max_x+1).count(&:on?) }
  end

  def to_s
    @rows.take(max_y+1).each{|row| puts row.take(max_x+1).map(&:to_s).join(" ")}
  end
end


position_data = data.select{|line| line.include?(',')}.map{|data| data.split(",").map(&:to_i)}
fold_data = data.select{|line| line.include?('fold')}

max_x  = position_data.max{ |a, b| a[0]  <=> b[0] }[0]
max_y  = position_data.max{ |a, b| a[1]  <=> b[1] }[1]

puts "max x #{max_x}, #{max_y}"
paper = InstructionPaper.new(max_x, max_y)

position_data.each do |position|
  paper.mark(position[0], position[1])
end

puts paper

puts "folds"
fold_data.each do |fold|
  puts fold
end

# paper.fold(fold_data[0])

fold_data.each {|data| paper.fold(data) }


puts paper

puts paper.number_on
