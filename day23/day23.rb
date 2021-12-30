require 'byebug'
data = File.readlines('day23.txt').map(&:chomp)

class Amphipod
  attr_accessor :letter, :cost_to_move

  def initialize(letter)
    @cost_to_move = cost_map[letter]
    @letter = letter
  end

  def same_type(other)
    letter == other.letter
  end

  def desired_room_location
    2 + (to_i - 'A'.to_i(16))*2
  end

  def cost_map
    @cost_map ||={ 'A'=> 1, 'B'=> 10, 'C'=> 100, 'D' => 1000}
    @cost_map 
  end

  def min_distance_to_correct_room(room)
    ( to_i - room.to_i).abs * cost_to_move
  end

  def to_i
    letter.to_i(16)
  end

  def to_s
    @letter.nil? ? "." : @letter
  end
end

class Room
  attr_accessor :desired_letter, :hallway_location, :first_occupant, :second_occupant

  def initialize(desired_letter, input_data)
    @desired_letter = desired_letter
    @hallway_location = 2 + (to_i - 'A'.to_i(16))*2
    @first_occupant = Amphipod.new(input_data[2][hallway_location+1])
    @second_occupant = Amphipod.new(input_data[3][hallway_location+1])
  end

  def complete?
    !first_occupant.nil? && first_occupant.letter == @desired_letter && !second_occupant.nil? && second_occupant.letter == desired_letter
  end

  def empty?
    first_occupant.nil? && second_occupant.nil?
  end

  def ready_for_amphipod?
    empty? || first_occupant.nil? && second_occupant.letter == desired_letter
  end

  def negative_energy
    return 0 if complete? || (first_occupant.nil? && second_occupant.nil?)
    cost = second_occupant.min_distance_to_correct_room(self)+second_occupant.cost_to_move
    unless first_occupant.nil?
      cost += first_occupant.min_distance_to_correct_room(self) 
      cost += (first_occupant.cost_to_move*100) if first_occupant.letter == desired_letter # move these first
    end
    cost
  end

  def to_i
    desired_letter.to_i(16)
  end

  def move_in(amphipod, steps_so_far)
    steps = steps_so_far + 1
    if @second_occupant.nil? 
      steps += 1
      @second_occupant = amphipod
    else
      @first_occupant = amphipod
    end
    amphipod.cost_to_move*steps
  end

  def to_s
    first_occupant.to_s+second_occupant.to_s
  end
end

class Hallway
  attr_accessor :locations, :start_idx, :end_idx

  def initialize()
    @locations = 11.times.map{nil}
    @start_idx = 1
    @end_idx = 9
  end

  def best_location_for_A(amphipod_room)
    if (((amphipod_room.hallway_location > 5)  || (!locations[start_idx].nil?)) && locations[end_idx].nil?)
      end_idx
    elsif locations[start_idx].nil?
      start_idx
    else
      byebug
    end
  end

  def best_location(amphipod, amphipod_room,active_room2)
    return best_location_for_A(amphipod_room) if amphipod.letter == 'A'
    desired_location = amphipod.desired_room_location
    room_locations = [amphipod_room.hallway_location, active_room2.hallway_location]
    min_hallway = room_locations.min
    max_hallway = room_locations.max
    if amphipod.to_i == amphipod_room.to_i && amphipod_room.to_i < active_room2.to_i && locations[amphipod_room.hallway_location+1].nil?
      amphipod_room.hallway_location+1
    elsif amphipod.to_i == amphipod_room.to_i && amphipod_room.to_i > active_room2.to_i && locations[amphipod_room.hallway_location-1].nil?
      amphipod_room.hallway_location-1
    elsif desired_location < min_hallway && clear?(amphipod_room.hallway_location, desired_location+1)
      desired_location+1
    elsif desired_location > max_hallway && clear?(amphipod_room.hallway_location, desired_location-1)
      desired_location-1
    elsif desired_location == active_room2.hallway_location && desired_location == min_hallway && clear?(amphipod_room.hallway_location, desired_location-1)
      desired_location-1
    elsif desired_location == active_room2.hallway_location && desired_location == max_hallway && clear?(amphipod_room.hallway_location, desired_location-1)
      desired_location+1
    else 
      if ((amphipod.letter == "A") || (amphipod.letter == "B")) && clear?(start_idx,amphipod_room.hallway_location) &&  # target the lower end of the halway 
        start_idx
      elsif ((amphipod.letter == "C") || (amphipod.letter == "D")) && clear?(amphipod_room.hallway_location, end_idx)
        end_idx
      elsif clear?(start_idx,amphipod_room.hallway_location)
        start_idx
      elsif clear?(amphipod_room.hallway_location, end_idx)
        end_idx
      elsif start_idx == 0 && clear?(start_idx+1,amphipod_room.hallway_location)
        start_idx+1
      elsif end_idx == 10 && clear?(amphipod_room.hallway_location,end_idx-1)
        end_idx-1
      else
        -1
      end
    end
  end

  def put_in_hallway(amphipod_room, active_room2)
    return 0 if amphipod_room.first_occupant.nil? && amphipod_room.second_occupant.nil?
    steps = -1
    best_amphipod1 =  best_location(amphipod_room.first_occupant, amphipod_room,active_room2)
    # no where to move in hallway
    return -1 if best_amphipod1 == -1

    cost = 0
    if !amphipod_room.second_occupant.nil? && amphipod_room.second_occupant.desired_room_location != amphipod_room.hallway_location
      best_amphipod2 =  best_location(amphipod_room.second_occupant, amphipod_room,active_room2)
      return -1 if best_amphipod2 == -1

      # in the same direction but 1 is in the way of two
      if (((best_amphipod2 > best_amphipod1) && (amphipod_room.hallway_location < best_amphipod1) && (amphipod_room.hallway_location < best_amphipod2)) ||
          ((best_amphipod2 < best_amphipod1) && (amphipod_room.hallway_location > best_amphipod1) && (amphipod_room.hallway_location > best_amphipod2)) ||
          (best_amphipod1 == best_amphipod2))
        if (amphipod_room.desired_letter == amphipod_room.first_occupant.letter)
          locations[best_amphipod1] = amphipod_room.first_occupant
          best_amphipod2 =  best_location(amphipod_room.second_occupant, amphipod_room,active_room2)
        else
          locations[best_amphipod2] = amphipod_room.second_occupant
          best_amphipod1 =  best_location(amphipod_room.first_occupant, amphipod_room,active_room2)
        end
      end
      locations[best_amphipod2] = amphipod_room.second_occupant
      steps = ((amphipod_room.hallway_location - best_amphipod2).abs + 2)
      cost = amphipod_room.second_occupant.cost_to_move*steps
      amphipod_room.second_occupant = nil
    end

    locations[best_amphipod1] = amphipod_room.first_occupant
    steps = (amphipod_room.hallway_location - best_amphipod1).abs + 1
    cost += amphipod_room.first_occupant.cost_to_move*steps
    amphipod_room.first_occupant = nil
    cost
  end

  def clear_to_room(room)
    cost = 0
    locations.each_with_index do |amphipod, index|
      next if amphipod.nil?
      loc = if room.hallway_location < index
              index-1
            else
              index+1
            end
      if room.desired_letter == amphipod.letter && clear?(loc,room.hallway_location)
        locations[index] = nil
        cost += room.move_in(amphipod, (room.hallway_location-index).abs)        
      end
    end
    cost
  end

  def clear_out(map)
    cost = 0
    puts map
    locations.each_with_index do |amphipod, index|
      next if amphipod.nil?
      room_to_move_to = map.find_room(amphipod)
      if (clear?(index+1, room_to_move_to.hallway_location))
        unless room_to_move_to.ready_for_amphipod?
          amphipod_to_move = room_to_move_to.first_occupant
          amphipod_to_move ||= room_to_move_to.second_occupant
          room2 = map.find_room(amphipod_to_move)
          if check_for_clear_halway(room2, room_to_move_to)
            if (map.move_first_room_occupant(room_to_move_to))
              map.move_second_room_occupant(room_to_move_to)            
            end
          else
            halway_cost = put_in_hallway(room_to_move_to, room_to_move_to)
            if halway_cost < 0 && room_to_move_to.first_occupant.nil?
              if index < room_to_move_to.hallway_location && locations[room_to_move_to.hallway_location+1].nil?
                halway_cost = room_to_move_to.second_occupant.cost_to_move*3
                locations[room_to_move_to.hallway_location+1] = room_to_move_to.second_occupant
                room_to_move_to.second_occupant = nil
              elsif index > room_to_move_to.hallway_location && locations[room_to_move_to.hallway_location-1].nil?
                halway_cost = room_to_move_to.second_occupant.cost_to_move*3
                locations[room_to_move_to.hallway_location-1] = room_to_move_to.second_occupant
                room_to_move_to.second_occupant = nil
              end
            end
            cost+= halway_cost
          end
        end
        loc = if room_to_move_to.hallway_location < index
          index-1
        else
          index+1
        end
        if room_to_move_to.ready_for_amphipod? && clear?(loc, room_to_move_to.hallway_location)
          locations[index] = nil
          cost += room_to_move_to.move_in(amphipod, (room_to_move_to.hallway_location-index).abs)        
        end
      end
    end
    return cost
  end

  def check_for_clear_halway(room1, room2)
    clear?(room1.hallway_location, room2.hallway_location)
  end

  def clear?(location1, location2)
    if location1 > location2
      save = location1
      location1 = location2
      location2 = save
    end
    (location1..location2).reduce(true){ |memo,location| memo && locations[location].nil? }
  end

  def to_s
    locations.map{|loc| loc.nil? ? "." : loc.to_s }.join("")
  end

end

class Map
  attr_accessor :hallway, :rooms, :total_cost

  def initialize(input_data)
    @rooms = []
    @hallway = Hallway.new()
    @rooms << Room.new('A', input_data)
    @rooms << Room.new('B', input_data)
    @rooms << Room.new('C', input_data)
    @rooms << Room.new('D', input_data)
    @total_cost = 0
  end

  def move
    return if rooms.reduce(true){|memo, room| memo && room.complete?}

    # find largest cost
    sorted_rooms = rooms.sort{ |room1, room2| room2.negative_energy  <=> room1.negative_energy }
    room_index = 0
    start_total_cost = @total_cost.clone
    while((start_total_cost == @total_cost) && (room_index < rooms.length))
      room_to_move = sorted_rooms[room_index]
      puts "move room #{room_to_move.desired_letter}"
      if !room_to_move.complete? && move_first_room_occupant(room_to_move)
        puts self
        if move_second_room_occupant(room_to_move)
          puts self
          @total_cost += hallway.clear_to_room(room_to_move)
          puts self
        end
      end
      room_index+=1
    end
    puts "#{@total_cost} started #{start_total_cost}"
    if start_total_cost != @total_cost
      move
    else
      cost = hallway.clear_out(self)
      if cost > 0
        @total_cost +=cost
        move
      end
    end
    rooms.reduce(true){|memo, room| memo && room.complete?}
  end

  def find_room(amphipod)
    rooms.select{|room| room.desired_letter == amphipod.letter}.first
  end

  def move_first_room_occupant(room_to_move)
    # no first occupant no need to move it
    return true if room_to_move.first_occupant.nil?

    # if we can get down the hall we can try to move this amphipod
    amphipod = room_to_move.first_occupant
    room_to_move_to = find_room(amphipod)
    return false unless hallway.check_for_clear_halway(room_to_move, room_to_move_to)
    amphipod = room_to_move.first_occupant
    # check that the room is ready
    unless room_to_move_to.ready_for_amphipod?
      # open a space in the room by moving everyone to the hallway
      cost = hallway.put_in_hallway(room_to_move_to, room_to_move) 
      return false if cost < 0
      @total_cost += cost
      @total_cost += hallway.clear_to_room(room_to_move_to)
    end
    return false unless hallway.check_for_clear_halway(room_to_move, room_to_move_to)

    # move to the room
    if room_to_move_to != room_to_move
      hallway_spaces = (room_to_move_to.hallway_location-room_to_move.hallway_location).abs + 1
      cost = room_to_move_to.move_in(room_to_move.first_occupant, hallway_spaces)
      room_to_move.first_occupant = nil
      @total_cost += cost  
    end
    return true
  end

  def move_second_room_occupant(room_to_move)
    # no first occupant no need to move it
    return true if room_to_move.second_occupant.nil? || room_to_move.desired_letter == room_to_move.second_occupant.letter

    # if we can get down the hall we can try to move this amphipod
    amphipod = room_to_move.second_occupant
    room_to_move_to = find_room(amphipod)

    # check that the room is ready
    unless room_to_move_to.ready_for_amphipod?
      # open a space in the room by moving everyone to the hallway
      cost = hallway.put_in_hallway(room_to_move_to, room_to_move)
      return false if cost < 0
      @total_cost += cost
      @total_cost += hallway.clear_to_room(room_to_move_to)
    end

    return false unless hallway.check_for_clear_halway(room_to_move, room_to_move_to)

    # move to the room
    hallway_spaces = (room_to_move_to.hallway_location-room_to_move.hallway_location).abs + 2
    cost = room_to_move_to.move_in(room_to_move.second_occupant, hallway_spaces)
    room_to_move.second_occupant = nil
    @total_cost += cost  
    return true
  end

  def to_s
    row1 = "  #{rooms.map{|room| room.first_occupant || "."}.join(" ")}"
    row2 = "  #{rooms.map{|room| room.second_occupant|| "."}.join(" ")}"
    "#{hallway}\n#{row1}\n#{row2}"
  end
end

map = Map.new(data)

puts map
if map.move
  puts "total cost = #{map.total_cost}"
else
  map = Map.new(data)
  puts "---- take two -----"
  puts map
  map.hallway.start_idx=0
  map.hallway.end_idx=10
  map.move
  puts "total cost = #{map.total_cost}"


end