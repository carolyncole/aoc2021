data = File.readlines('day3.txt').map(&:chomp)

def most_common(binary_list, most_common_result = "1", least_common_result = "0")
  number_of_ones = binary_list.count {|binary| binary == "1"}
  number_of_zeros = binary_list.count {|binary| binary == "0"}
  if number_of_ones >= number_of_zeros
    most_common_result
  else
    least_common_result
  end  
end
def gama_binary(binary_list)
  length = binary_list.first.size
  puts length
  (0..length-1).map do |index|
    most_common(binary_list.map{|number|number[index]})
  end.join
end
def epsilon_binary(gama_binary)
  gama_binary.split("").map {|char| char == '1' ? '0' : '1' }.join
end

gb =  gama_binary(data) 
puts "gamma = #{gb}"
eb =  epsilon_binary(gb) 
puts "epsilon = #{eb}"
puts gb.to_i(2) * eb.to_i(2)

def get_rating_list(binary_list, idx=0, most_common_result = "1", least_common_result = "0" )
  return binary_list if binary_list.size == 1
  selector = most_common(binary_list.map{|number|number[idx]}, most_common_result, least_common_result)
  puts "selector #{selector} #{idx} #{binary_list.size}"
  binary_list = binary_list.select{|bin| bin[idx] == selector }
  get_rating_list(binary_list, idx+1, most_common_result, least_common_result)
end

oxygen_rating = get_rating_list(data).first
co2_rating = get_rating_list(data, 0, "0", "1").first

puts "oxygen rating #{oxygen_rating}"
puts "co2 rating #{co2_rating}"
puts oxygen_rating.to_i(2) * co2_rating.to_i(2)
