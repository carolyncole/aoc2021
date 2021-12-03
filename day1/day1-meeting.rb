data = File.read('day1-meeting-two.txt').split #.map(&:to_i)
increases = 0
data.each_cons(2) do |depths|
  increases +=1 if depths[1] > depths[0]
end
puts increases
