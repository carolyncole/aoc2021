data = File.readlines('day2.txt')
def move(command, location)
 action, size = command.split(" ")
 size = size.to_i
 case action
 when "forward"
   {depth: location[:depth] + location[:aim]*size, position: location[:position] + size, aim: location[:aim]}
 when "up"
   {depth: location[:depth], position: location[:position], aim: location[:aim] - size}
 when "down" 
   {depth: location[:depth], position: location[:position], aim: location[:aim] + size}
 end
end
location = {depth: 0, position: 0, aim: 0}
data.select do |command|
   location = move(command,location)
   puts location
end
puts location[:position]*location[:depth]
