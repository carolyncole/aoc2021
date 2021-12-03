data = File.readlines('day2.txt')
depth = 0
aim = 0
location = 0
data.select do |command|
 action, size = command.split(" ")
 size = size.to_i
 case action
 when "forward"
   location += size
   depth += aim*size
 when "up"
   aim -= size
 when "down"
   aim +=size
 end
end
puts location*depth

