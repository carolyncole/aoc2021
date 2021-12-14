require 'byebug'
data = File.readlines('day14.txt').map(&:chomp)

class FormulaMapping
  attr_accessor :formula_map

  def initialize(data)
    @formula_map = data.map {|data| data.split(" -> ")}.to_h
  end

  def apply(input)
    output = input.clone
    inserts  = []
    (0..input.length-2).each do |index|
      pair = input[index,2]
      insert = formula_map[pair]
      unless insert.nil?
        inserts << { index: index+1, letter: insert }
      end
    end
    inserts.each_with_index{|pair, index| output.insert(pair[:index]+index,pair[:letter]) }
    output
  end

  def to_s
    formula_map.map{|key, value| "#{key} -> #{value}"}.join("\n")
  end
end

original_formula = data.first
formula_mapping = FormulaMapping.new(data.drop(2))

output =  original_formula

20.times { output = formula_mapping.apply(output) }
puts output.length
tally = output.split("").tally
max = tally.max{|a,b| a[1] <=> b[1] }
min =  tally.min{|a,b| a[1] <=> b[1] }
puts (max[1] - min[1])
