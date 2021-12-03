data = File.readlines('day2.txt')
forward_distance = data.select{|command| command.start_with?("forward")}.map{|command| command.split(" ")[1].to_i}.sum
increase_depth = data.select{|command| command.start_with?("down")}.map{|command| command.split(" ")[1].to_i}.sum
decrease_depth = data.select{|command| command.start_with?("up")}.map{|command| command.split(" ")[1].to_i}.sum
puts forward_distance*(increase_depth-decrease_depth) 
