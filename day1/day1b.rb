depths = File.read("day1.txt").split
increases = 0
last = nil
index = 0
while index < depths.length
  depth = depths[index].to_i + depths[index+1].to_i + depths[index+2].to_i
  if last!= nil && depth > last
    increases+= 1
  end
  last = depth
  index +=1
end 
puts increases
