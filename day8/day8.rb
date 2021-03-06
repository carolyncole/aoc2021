require 'byebug'

lines = File.readlines('day8.txt').map(&:chomp)

# counts = { 2 => {count:0, number: 1 }, 
#            3 =>{ count:0, number: 7 }, 
#            4 => {count: 0, number: 4 }, 
#            7 => {count: 0, number: 8 } }
# lines.each do |line|
#   numerics, code_set = line.split(" | ")
#   code_set.split(" ").each do |code| 
#     known_code = counts[code.length]
#     known_code[:count] +=1 if known_code.nil?
#   end
# end
# puts counts.values
# puts counts.values.reduce(0){|sum, value| sum+= value[:count] }

numbers = lines.map do |line|
  all_nine_numbers, code_set = line.split(" | ")
 
  cypher_by_length = { 2 => {number: 1, letters: nil }, 
           3 => { number: 7, letters: nil }, 
           4 => { number: 4, letters: nil }, 
           5 => { number: nil, letters: [] }, 
           6 => { number: nil, letters: [] }, 
           7 => { number: 8, letters: nil } 
          }
  all_nine_numbers.split(" ").each do |code| 
    cypher_info = cypher_by_length[code.length]
    letters = code.split("").sort
    if cypher_info[:number].nil?
      cypher_info[:letters] << letters unless cypher_info[:letters].include?(letters)  
    else
      cypher_info[:letters] = letters if cypher_info[:letters].nil?
    end
  end
  
  top = (cypher_by_length[3][:letters]-cypher_by_length[2][:letters]).first
  right_bottom = ((cypher_by_length[6][:letters].reduce(&:&)) & cypher_by_length[2][:letters]).first
  right_top = (cypher_by_length[2][:letters] - [right_bottom]).first
  middle = ((cypher_by_length[5][:letters].reduce(&:&)) & cypher_by_length[4][:letters]).first
  bottom =  (cypher_by_length[5][:letters].reduce(&:&) - [top] - [middle]).first
  left_top = (cypher_by_length[4][:letters] - cypher_by_length[2][:letters] - [middle]).first
  left_bottom = (cypher_by_length[7][:letters] - cypher_by_length[3][:letters] - cypher_by_length[4][:letters]- [bottom]).first

  number_key =  {
   [top,left_top,left_bottom, bottom,right_bottom, right_top].sort => 0,
   [right_top, right_bottom].sort => 1,
   [top, middle, bottom, right_top, left_bottom].sort => 2,
   [top, middle, bottom, right_top, right_bottom].sort => 3,
   [left_top, middle, right_top, right_bottom].sort => 4,
   [top, middle, bottom, left_top, right_bottom].sort => 5,
   [top, middle, bottom, left_top, left_bottom, right_bottom].sort => 6,
   [top, right_top, right_bottom].sort => 7,
   [top, middle, left_top,left_bottom, bottom,right_bottom, right_top].sort => 8,
   [top,left_top,middle, bottom,right_bottom, right_top].sort => 9,
  }
  number_key[code_set.split(" ")[0].split("").sort]*1000+ number_key[code_set.split(" ")[1].split("").sort]*100 + number_key[code_set.split(" ")[2].split("").sort]*10+ number_key[code_set.split(" ")[3].split("").sort]
end

puts numbers.sum
