depths = File.read("day1.txt").split
increases = 0
last = nil
depths.each do |depth|
  depth = depth.to_i
  if last!= nil && depth > last
    increases+= 1
  end
  puts "#{last} #{depth} #{increases}"
  last = depth
end 
puts increases
