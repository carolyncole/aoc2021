require 'byebug'
data = File.readlines('day4.txt').map(&:chomp)

class Value
  attr_accessor :number, :called
  def initialize(number)
    @number = number
    @called = false
  end

  def call(number_called)
    @called = true if number == number_called
  end

  def to_s
    "#{number} #{called}"
  end
end

class Board
  attr_accessor :rows, :columns

  def initialize(numbers)
    @rows = numbers.map{|row| convert_row(row)}
    column_numbers = []
    numbers.transpose.each {|row| column_numbers << row.reverse}
    @columns = column_numbers.map{|row| convert_row(row)}
  end

  def call(number)
    @rows.each{|values| values.each{|value| value.call(number)}}
    @columns.each{|values| values.each{|value| value.call(number)}}
  end

  def winner?
    @rows.any?{|row| row.all?(&:called)} || @columns.any?{|row| row.all?(&:called)}
  end

  def to_s
    @rows.each{|row| puts row.map(&:to_s).join(" ")}
  end

  def convert_row(row)
    row.map do |number| 
      Value.new(number.to_i)
    end
  end

  def unmarked_sum
    @rows.sum{|values| values.reject(&:called).sum(&:number) }
  end
end


numbers_to_call = data.slice!(0).split(",").map(&:to_i)
boards = []
while (data.length > 5)
  data.slice!(0) # skip line break
  board_data = data.slice!(0, 5)
  boards << Board.new( board_data.map{|line| line.split(" ")})
end

winning_index = 0
numbers_to_call.each_with_index do |number_called, number_index|
  boards.each{|board| board.call(number_called)}
  if boards.any?(&:winner?)
    winning_index = number_index
    break
  end
  boards.each_with_index do |board, index|
    puts "board #{index}"
    puts board
  end
end

puts winning_index
winning_board = boards.select(&:winner?).first
puts winning_board.unmarked_sum * numbers_to_call[winning_index]


numbers_to_call.each_with_index do |number_called, number_index|
  boards.each{|board| board.call(number_called)}
  boards.any?(&:winner?)
    winning_index = number_index
    break
  end
  boards.each_with_index do |board, index|
    puts "board #{index}"
    puts board
  end
end
