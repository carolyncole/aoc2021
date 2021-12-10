require 'byebug'
data = File.readlines('day10.txt').map(&:chomp)

def closes_for(item)
  case item
  when ')'
    '('
  when ']'
    '['
  when '>'
    '<'
  when '}'
    '{'
  end
end

def opens_for(item)
  case item
  when '('
    ')'
  when '['
    ']'
  when '<'
    '>'
  when '{'
    '}'
  end
end

def check_line(line)
  blocks = []
  line.split("").each do |char|
    case char
    when '(', '[', '{', '<' # open
      blocks << { open: char }
    when ')', ']', '}', '>' # close
      if blocks.last[:open] == closes_for(char)
        blocks.pop
      else
        return char
      end
    end
  end
  nil
end 

def complete_line(line)
  blocks = []
  line.split("").each do |char|
    case char
    when '(', '[', '{', '<' # open
      blocks << { open: char }
    when ')', ']', '}', '>' # close
      if blocks.last[:open] == closes_for(char)
        blocks.pop
      end
    end
  end
  blocks.reverse.map do |block|
    opens_for(block[:open])
  end
end 

bad_lines = []
good_lines = data.select do |line|
  bad_char = check_line(line)
  unless bad_char.nil?
    bad_lines << {line: line, bad_char: bad_char}
  end
  bad_char.nil?
end

# bad_lines.each do |tally|
#   puts "#{tally[:line]} #{tally[:bad_char]}"
# end


point_map = { ')' => 3,']' => 57, '}' => 1197, '>' => 25137}

puts bad_lines.sum{|bad| point_map[bad[:bad_char]]}


complete_point_map = { ')' => 1,']' => 2, '}' => 3, '>' => 4}

scores = good_lines.map do |line|
          completing_chars = complete_line(line)
          score = completing_chars.reduce(0){|total,char| total*5 + complete_point_map[char]}
        end

puts scores.sort[scores.length/2]