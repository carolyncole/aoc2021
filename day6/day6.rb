require 'byebug'

class LanternFish
  attr_accessor :passes
  def initialize(list, days_to_spawn)
    @list = list
    @days_to_spawn = days_to_spawn
  end

  def day_passes
    if @days_to_spawn == 0
      spawn
    else
      @days_to_spawn-=1
    end
  end

  def spawn
    @days_to_spawn = 6
    @list << LanternFish.new(@list, 8)
  end

  def to_s
    @days_to_spawn.to_s
  end
end

##
# Nothing above here was used for th final solution
##

school_data = File.read('day6.txt').split(",").map(&:to_i)

# school_of_fish = []
# school_data.each{ |days_to_spawn| school_of_fish <<  LanternFish.new(school_of_fish, days_to_spawn) }

school_of_fish = (0..8).map{|idx| school_data.count(idx)}
(1..256).each do |day|
   number_to_spawn = 0
   school_of_fish.each_with_index do |number_fish, index|
    if index == 0
      number_to_spawn = number_fish
    else
      school_of_fish[index -1 ] = number_fish
    end
  end
  school_of_fish[6] += number_to_spawn
  school_of_fish[8] = number_to_spawn
  puts "Done with Day #{day}"
end

#puts school_of_fish.join(", ")
#puts school_of_fish.size
puts school_of_fish.join(", ")
puts school_of_fish.sum
