data = File.read('day1-full.txt').split.map(&:to_i)
increases = 0
sums = data.each_cons(3).map(&:sum)
sums.each_cons(2) do |depths|
  increases +=1 if depths[1] > depths[0]
end
puts increases
