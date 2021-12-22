require 'byebug'
require 'date'
require 'json'

data = File.readlines('day18.txt').map(&:chomp)

class SnailValue
  attr_accessor :parent, :value, :root, :exit_explosions_now, :exit_split_now

  def initialize(value, parent: nil)
    @value = value
    @parent = parent
    @root  = nil
    @exit_explosions_now = false
    @exit_split_now = false
  end

  def total_explosions
    0 # numbers can not explode
  end

  def add_right(num)
    @value += num.value
  end

  def add_left(num)
    @value += num.value
  end

  def assign_depth(_depth, root)
    @root = root
    # noop
  end

  def check_for_explosions
    # noop
  end

  def split
    return self if @value <= 9
    @exit_split_now = true
    left_num = @value/2
    right_num = (@value/2.0).ceil
    pair = NumberPair.new(SnailValue.new(left_num), 
                   SnailValue.new(right_num),
                   parent: parent)
    pair
  end

  def to_s
    @value
  end

end

class NumberPair
  attr_accessor :left, :right, :depth, :parent, :num_explosions, :root, :exit_split_now, :exit_explosions_now

  def initialize(left, right, depth: 1, parent: nil)
    @depth = depth
    @parent = parent
    @num_explosions  = 0
    @left = left
    @right = right
    left.parent = self
    right.parent = self
    @exit_explosions_now = false
    @exit_split_now = false
  end

  def assign_depth(depth, root)
    @depth = depth
    @root = root
    @left.assign_depth(depth+1, root)
    @right.assign_depth(depth+1, root)
  end

  def check_for_explosions
    @exit_explosions_now = false
    @exit_explosions_now = @left.check_for_explosions
    return true if @exit_explosions_now
    @exit_explosions_now = @right.check_for_explosions
    return true if @exit_explosions_now
    if depth >= 5
      parent.explode(self)
      true
    end 
  end

  def split
    new_left = @left.split
    just_split = @left.is_a?(SnailValue) && new_left.is_a?(NumberPair)
    @exit_split_now = @left.exit_split_now
    @left = new_left
    puts "S       #{root.to_s}" if just_split
    return self if @exit_split_now
    new_right = @right.split
    @exit_split_now = @right.exit_split_now
    just_split = @right.is_a?(SnailValue) && new_right.is_a?(NumberPair)
    @right = new_right
    puts "S       #{root.to_s}" if just_split
    self
  end

  def total_explosions
    @num_explosions + left.total_explosions + right.total_explosions
  end

  def explode(child)
    @num_explosions+=1
    if child == right
      # add child.left to the left pair
      explode_right(@right)
      @right = SnailValue.new(0, parent: self)
    else
      explode_left(@left)
      @left = SnailValue.new(0, parent: self)
    end
    puts "E #{child} #{root.to_s}"
  end

  def explode_right(child)
    @left.add_right(child.left)
    # add child.right to the parent's left child
    add_parent_right(child.right)
  end

  def add_parent_right(num)
    return if parent.nil?
    if parent.right != self
      parent.right.add_left(num)
    else
      parent.add_parent_right(num)
    end
  end

  def explode_left(child)
      # add child.left to the parent's right child
      add_parent_left(child.left)

      @right.add_left(child.right)
  end

  def add_parent_left(num)
    return if parent.nil?
    if parent.left != self
      parent.left.add_right(num)
    else
      parent.add_parent_left(num)
    end
  end

  def add_left(num)
    @left.add_left(num)
  end

  def add_right(num)
    @right.add_right(num)
  end
    
  def to_s
    "[#{left.to_s},#{right.to_s}]"
  end
end

def gen_number(values)
  if values.is_a? Array
    NumberPair.new(gen_number(values[0]), gen_number(values[1]))
  else
    SnailValue.new(values)
  end
end

number = nil
data.each do |part_str|
  parts = JSON.parse part_str
  new_number = NumberPair.new(gen_number(parts[0]), gen_number(parts[1]))
  if number.nil?
    number = new_number
  else
    number = NumberPair.new(number, new_number)
    puts number
  end
  last_number = ""
  while (last_number != number.to_s)
    last_number = number.to_s
    total_explosions = -1
    while (number.total_explosions > total_explosions)
      total_explosions = number.total_explosions
      number.assign_depth(1, number)
      number.check_for_explosions
    end
    number.assign_depth(1, number)
    number.split
  end
  puts "F #{number}"
  # byebug
end

puts number