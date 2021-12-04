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
    @columns = @rows.transpose.reverse
  end

  def call(number)
    @rows.each{|values| values.each{|value| value.call(number)}}
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
boards = data.each_slice(6).map do |data_slice|
           board_data = data_slice.reject(&:empty?)
           Board.new( board_data.map{|line| line.split(" ")})
         end

winning_index = 0
numbers_to_call.each_with_index do |number_called, number_index|
  boards.each{|board| board.call(number_called)}
  if boards.any?(&:winner?)
    winning_index = number_index
    break
  end
end

puts winning_index
winning_board = boards.select(&:winner?).first
puts winning_board.unmarked_sum * numbers_to_call[winning_index]


loosing_board = nil
numbers_to_call.each_with_index do |number_called, number_index|
  boards.each{|board| board.call(number_called)}
  if boards.count(&:winner?) == (boards.length-1)
    loosing_board = boards.reject(&:winner?).first
  end
  if boards.all?(&:winner?)
    winning_index = number_index
    break
  end
end

puts winning_index

puts loosing_board.unmarked_sum * numbers_to_call[winning_index]
