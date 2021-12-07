require 'byebug'

def medain(sorted_array)
  sorted_array[(sorted_array.size/2).floor]
end  

def average(sorted_array)
  (sorted_array.sum.to_f/sorted_array.size).round
end  

def to_location(current_location, new_location)
  (current_location - new_location).abs
end

def to_location2(current_location, new_location)
  fuel = 0
  (current_location - new_location).abs.times do |idx|
    fuel+=(idx+1)
  end
  fuel
end


crab_data = File.read('day7.txt').split(",").map(&:to_i)
median =  medain(crab_data.sort)
puts crab_data.map{|crab| to_location(crab,median) }.sum


average =  average(crab_data)
puts average

min = [crab_data.map{|crab| to_location2(crab,average-1) }.sum,
       crab_data.map{|crab| to_location2(crab,average) }.sum,
       crab_data.map{|crab| to_location2(crab,average+1) }.sum].min

puts min




# school_of_fish = (0..8).map{|idx| school_data.count(idx)}
# (1..256).each do |day|
#    number_to_spawn = 0
#    school_of_fish.each_with_index do |number_fish, index|
#     if index == 0
#       number_to_spawn = number_fish
#     else
#       school_of_fish[index -1 ] = number_fish
#     end
#   end
#   school_of_fish[6] += number_to_spawn
#   school_of_fish[8] = number_to_spawn
#   #puts "Done with Day #{day}"
# end

# #puts school_of_fish.join(", ")
# #puts school_of_fish.size
# puts school_of_fish.join(", ")
# puts school_of_fish.sum
