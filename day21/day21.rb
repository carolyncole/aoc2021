require 'byebug'
# data = File.readlines('day21.txt').map(&:chomp)

class DeterministicDice
  attr_accessor :value, :number_of_rolls

  def initialize
    @value = 0
    @number_of_rolls = 0
  end

  def roll
    @number_of_rolls+=1
    @value +=1
    if @value > 100
      @value = 1
    end
    @value
  end

  def to_s
    "#{@value}"
  end
end

class QuantumDice
  attr_accessor :value, :number_of_rolls, :single_board

  def initialize
    @value = 0
    @number_of_rolls = 0
    @single_board = SingleBoard.new
  end

  def roll_by_3(player_list)
    current_player = (number_of_rolls) % 2
    new_players_list = []
    player_list.each do |count, players|
      next unless single_board.winner(players).nil?

      possible_rolls = {3=>1, 4=>3, 5=>6, 6=>7, 7=>6, 8=>3, 9=>1}
      possible_rolls.each do |roll, roll_count|
        new_players = players.map(&:clone)
        single_board.take_turn(roll, new_players, current_player)
        new_players_list << [count*roll_count, new_players]
      end
    end
    @number_of_rolls+=1
    new_players_list
  end

  def roll(board_list)
    new_board_list = []
    board_list.each do |board|
      3.times.each do |idx|
        new_board = board.clone()
        new_board.deep_clone()
        new_board.roll(idx)
        new_board_list <<  new_board
      end
    end
    new_board_list
  end

  def to_s
    "#{@value}"
  end
end

class Player
  attr_accessor :location, :score

  def initialize(location)
    @location = location
    @score = 0
  end

  def move_to(location)
    @score += location
    @location = location
  end

  def to_s
    "score: #{score} location #{location}"
  end

  def deep_clone
    @location = @location.clone
    @score = @score.clone
  end
end

class SingleBoard

  def initialize(winning_score: 21)
    @winning_score = winning_score
  end

  def take_turn(spaces, players, current_player)
    return nil unless winner(players).nil?
    move(players[current_player],spaces)
    (current_player+1) % 2
  end

  def winner(players)
    players.select{|player| player.score >= @winning_score}.first
  end

  def move(player, spaces)
    if spaces >= 10
      number_around = spaces/10
      spaces -= 10*number_around
    end
    location = player.location + spaces
    location = location - 10 if location > 10
    player.score+=location
    player.location=location
  end
end

class Board
  attr_accessor :players, :current_player

  def initialize(players, winning_score: 1000)
    @current_player = 0
    @players = players
    @winning_score = winning_score
    @rolls = []
  end

  def roll(value)
    @rolls << value
    no_winner = true
    if @rolls.length == 3
      no_winner = take_turn(@rolls.sum)
      @rolls = []
    end
    no_winner
  end

  def take_turn(spaces)
    return false unless winner.nil?
    move(players[current_player],spaces)
    @current_player = (current_player+1) % 2
    winner.nil?
  end

  def winner
    players.select{|player| player[0] >= @winning_score}.first
  end

  def looser
    return nil if winner.nil?
    players.select{|player| player[0] < @winning_score}.first
  end

  def move(player, spaces)
    if spaces >= 10
      number_around = spaces/10
      spaces -= 10*number_around
    end
    location = player[1] + spaces
    location = location - 10 if location > 10
    player[0]+=location
    player[1]=location
  end

  def deep_clone
    @players = @players.map(&:clone)
    @rolls = @rolls.clone
    @current_player = @current_player.clone
  end
end

# player1 = Player.new(4)
# player2 = Player.new(8)

player1 = Player.new(7)
player2 = Player.new(5)

board = Board.new([[0,7],[0,5]])
dice = DeterministicDice.new()
no_winner = true
while (no_winner) do
  no_winner = board.roll(dice.roll)
end

# looser = board.looser
# puts looser[0] * dice.number_of_rolls
# player1 = Player.new(7)
# player2 = Player.new(5)

# # boards = [Board.new([[0,7],[0,5]], winning_score: 21)]
# # qdice = QuantumDice.new

# # 3.times do
# #   boards = qdice.roll(boards)
# # end

# player1 = [0,5]
# player2 = [0,7]
# player_list = [[1,[Player.new(5),Player.new(7)]]]
# qdice = QuantumDice.new

# 5.times do
#   player_list = qdice.roll_by_3(player_list)
# end
# # puts "-- Quantum -- "

# # lines =  boards.sort{|a,b|a.players[0][0] <=> b.players[0][0]}.each{|count, board| board.to_s }.join("\n")
# # puts lines.split("\n").count
# # puts lines
# # puts "-- Quantum by 3 -- "
# lines =  player_list.map{|count, players| count.times.map{"P1 #{players[0]} P2 #{players[1]}"}.join("\n") }.join("\n")
# # puts lines.split("\n").count
# puts lines
# byebug
# # puts "Player 1 won #{player_list.select{|count, players| players[0][0]>=21}.sum{|count, players| count}} times"
# # puts "Player 2 won #{player_list.select{|count, players| players[1][0]>=21}.sum{|count, players| count}} times"
# puts "Player 1 won #{player_list.select{|count, players| players[0].score >=21}.sum{|count,players| count}} times"
# puts "Player 2 won #{player_list.select{|count, players| players[1].score >=21}.sum{|count,players| count}} times"

player_values = {}
roll_spread = {3=>1, 4=>3, 5=>6, 6=>7, 7=>6, 8=>3, 9=>1}
{3=>1, 4=>3, 5=>6, 6=>7, 7=>6, 8=>3, 9=>1}.keys.each do |key| 
  player_values[key] = [[4],[8]]
end
any_not_winning = true

idx = 0
while(any_not_winning) do 
  puts idx 
  idx +=1
  new_player_values = {}
  any_not_winning = false
  player_values.each do |player_key,value|
    if value[0][1..].sum >= 21 || value[1][1..].sum >= 21
      new_player_values[player_key] = value
    else
      current_location1 = value[0].last
      current_location2 = value[1].last
      any_not_winning = true
      roll_spread.each do |key,roll_s|
        new_key = [player_key,key]
        location1 = current_location1+ key
        location1 -=10 if location1 > 10
        player1_locations = value[0] + [location1]
        if player1_locations[1..].sum < 21
          roll_spread.each do |key2,rolls2|
            new_key2 = [new_key,key2]
            location2 = current_location2+ key
            location2 -=10 if location2 > 10
            new_player_values[new_key2] = []
            new_player_values[new_key2][0] = player1_locations.clone
            new_player_values[new_key2][1] = value[1] + [location2]
          end
        else
          new_player_values[new_key] = []
          new_player_values[new_key][0] = player1_locations
          new_player_values[new_key][1] = value[1].clone
        end
      end
    end
  end
  player_values = new_player_values
end

player1_wins = player_values.select{|key,values|  values[0][1..].sum >= 21}
player2_wins = player_values.select{|key,values|  values[1][1..].sum >= 21}

player1_total = player1_wins.reduce(0) do |total_wins,values| 
  total_wins + values[0].flatten.reduce(1){|total,key| total * roll_spread[key]}
end

player2_total = player2_wins.reduce(0) do |total_wins,values| 
  total_wins + values[0].flatten.reduce(1){|total,key| total * roll_spread[key]}
end

byebug
puts "total #{player1_total}"