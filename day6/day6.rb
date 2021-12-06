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

school_data = File.read('day6.txt').split(",").map(&:to_i)

school_of_fish = []
school_data.each{ |days_to_spawn| school_of_fish <<  LanternFish.new(school_of_fish, days_to_spawn) }
(1..256).each do |day|
   original_length = school_of_fish.size
   (0..(original_length-1)).each {|idx| school_of_fish[idx].day_passes}
   puts "Done with Day #{day}"
end

#puts school_of_fish.join(", ")
puts school_of_fish.size
