require 'byebug'
data = File.readlines('day17.txt').map(&:chomp)

# y0 = 0
# x0 = 0

# y any aim
# y = y0 + t(Vy - 1t)


# y = t(Vy -1t)
# y/t = Vy - 1t
# Vy = y/t + 1t
# -1t*t +tVy -y = 0
# a = -1 b = Vy c = -y
# t = (-Vy +- SQRT(Vy*Vy -4y))/-2

# x aim positive
# x = x0 + t*(Vx -1t)

# x = t(Vx-1t)
# x/t = Vx - 1t
# Vx = x/t + 1t
# x = tVx - t*t
# -1t*t +tVx - x = 0
# a = -1 b = Vx c = -x
# t = (-Vx +- SQRT(Vx*Vx -4x))/-2


# x aim negative
# x = x0 + t*(Vx + 1t) negative x
# x = t(Vx + 1t)
# x/t = Vx + 1t
# Vx = x/t - 1t
# 1t*t +tVx - x = 0
# a = 1 b = Vx c = -x
# t = (-Vx +- SQRT(Vx*Vx +4x))/2


# for the range of X positions solve the equation using the final position
# for th range of Y positions solve the equation using the final position
# then find max y ant any time for each solution

def in_range_x_y(initial_velocity_x, initial_velocity_y, range_x_start, range_x_stop, range_y_start, range_y_stop)
  current_velocity_x = initial_velocity_x.clone
  current_velocity_y = initial_velocity_y.clone
  new_x = 0
  new_y = 0
  byebug if initial_velocity_x == 6 && initial_velocity_y == 0
  while (should_stop(new_x, range_x_start, range_x_stop) && should_stop(new_y, range_y_start, range_y_stop))
    new_x +=  current_velocity_x
    new_y +=  current_velocity_y
    return true if within_range(new_x, range_x_start, range_x_stop) && within_range(new_y, range_y_start, range_y_stop)
    if current_velocity_x > 0
      current_velocity_x -= 1
    elsif current_velocity_x < 0
      current_velocity += 1
    end
    current_velocity_y -=1
  end
  return false
end


def in_range_x(initial_velocity, range_start, range_stop)
  current_velocity = initial_velocity.clone
  new_x = 0
  time_t = 0
  times_in_range = []
  while (should_stop(new_x, range_start, range_stop) && current_velocity >= 0)
    new_x +=  current_velocity
    if within_range(new_x, range_start, range_stop)
      if (current_velocity == 0 )
        times_in_range << [:all_time_after, time_t] 
        return times_in_range
      else
        times_in_range << time_t - 1 if times_in_range.empty?
        times_in_range << time_t
      end
    end
    if current_velocity >= 0
      current_velocity -= 1
    else
      current_velocity += 1
    end
    time_t +=1
  end
  return times_in_range
end

def in_range_y(initial_velocity, range_start, range_stop)
  current_velocity = initial_velocity.clone
  new_y = 0
  time_t = 0
  times_in_range = []
  while (should_stop(new_y, range_start, range_stop))
    new_y +=  current_velocity
    current_velocity -= 1
    if within_range(new_y, range_start, range_stop)
      times_in_range << time_t.clone
    end
    time_t +=1
  end
  return times_in_range
end

def within_range(value, range_start, range_stop)
  stop = if range_stop < range_start
           range_start
         else
           range_stop
         end
  start = if range_stop < range_start
          range_stop
        else
          range_start
        end
  value >= start && value <= stop
end

def should_stop(value, range_start, range_stop)
  if range_stop < 0
    stop = if range_stop > range_start
              range_start
            else
              range_stop
            end
            value > stop
  else
    stop = if range_stop < range_start
              range_start
            else
              range_stop
            end
    value < stop
  end
end


_nada, _nada, x_range_str, y_range_str = data.first.split(" ")
x_range = x_range_str[2..-1].split("..").map(&:to_i)
y_range =  y_range_str[2..].split("..").map(&:to_i)

valid_y = {}
y_range_num = if y_range[0].abs > y_range[1].abs
                y_range[0].abs
              else
                y_range[1].abs
              end
((-1*y_range_num)..y_range_num).each do |velocity|
  times_in_range = in_range_y(velocity, y_range[0], y_range[1])
  times_in_range.each do |time_t|
    valid_y[time_t] ||= []
    valid_y[time_t] << velocity 
  end
end
puts (1..(valid_y.values.flatten.max)).sum

valid_x = {}
(1..x_range[1]).each do |velocity|
  times_in_range = in_range_x(velocity, x_range[0], x_range[1])
  times_in_range.each do |time_t|
    valid_x[time_t] ||=[]
    valid_x[time_t] << velocity 
  end
end
valid_xy = []
(1..x_range[1]).each do |velocity_x|
  ((-1*y_range_num)..y_range_num).each do |velocity_y|
    valid_xy << [velocity_x, velocity_y] if in_range_x_y(velocity_x, velocity_y, x_range[0], x_range[1], y_range[0], y_range[1])
  end
end



# max_time = valid_y.keys.max
# valid_xy = []
# valid_x.each do | time, velocities| 
#   in_time = if time.is_a? Integer
#                [time]
#             else
#               (time[1]..max_time).reject{|time_range| valid_y[time_range].nil?}
#             end
#  in_time.each do |y_time|
#     next if valid_y[y_time].nil?
#     velocities.each do |velocity_x|
#       unless valid_y[y_time].nil?
#         valid_y[y_time].each do |velocity_y|
#           valid_xy << [velocity_x, velocity_y] unless valid_xy.include?([velocity_x, velocity_y])
#         end
#       end
#     end
#   end
# end
# puts valid_xy.map{|x,y| "(#{x},#{y})"}.join(", ")


data2 = File.readlines('day17-intermediate.txt').map(&:chomp)
wanted = data2.map(&:split).flatten.map {|value| value.split(",").map(&:to_i)}.uniq.sort
# verified have the correct numbers of x and y
# wanted_x = data2.map(&:split).flatten.map {|value| value.split(",")[0].to_i}.uniq.sort
# puts (valid_x.values.flatten.uniq- wanted_x).join(" missing x, ")
# wanted_y = data2.map(&:split).flatten.map {|value| value.split(",")[1].to_i}.uniq.sort
# puts (valid_y.values.flatten.uniq- wanted_y).join(" missing y, ")
# puts wanted.map{|x,y| "(#{x},#{y})"}.join(", ")
# no more unwanted ones
puts (valid_xy - wanted).map{|x,y| " unwanted (#{x},#{y})"}.join(", ")
puts (wanted- valid_xy ).map{|x,y| " missing (#{x},#{y})"}.join(", ")
puts valid_xy.count
