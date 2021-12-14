require 'byebug'
require 'date'
data = File.readlines('day14.txt').map(&:chomp)

class FormulaMapping
  attr_accessor :formula_map

  def initialize(data)
    @formula_map = data.map {|data| data.split(" -> ")}.to_h
  end

  def apply(input)
    output = input.clone
    input.each do |key, number|
      letter = formula_map[key]
      unless letter.nil?
        new_key_left = key[0]+letter
        new_key_right = letter+key[1]
        output[key] -= number
        output[new_key_left] ||= 0
        output[new_key_right] ||= 0
        output[new_key_left] += number
        output[new_key_right] += number
      end
    end
    output
  end

  def to_s
    formula_map.map{|key, value| "#{key} -> #{value}"}.join("\n")
  end
end

original_formula = data.first
formula_mapping = FormulaMapping.new(data.drop(2))

pairs =  original_formula.split("").each_cons(2)
output = pairs.map(&:join).tally

40.times { output = formula_mapping.apply(output) }
tally = {}
output.each do |key,value| 
  tally[key[0]]||=0
  tally[key[0]]+=value
end
tally[original_formula.split("").last] +=1
max = tally.to_a.max{|a,b| a[1] <=> b[1] }
min =  tally.to_a.min{|a,b| a[1] <=> b[1] }
puts (max[1] - min[1])
