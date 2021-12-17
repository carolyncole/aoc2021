require 'byebug'
data = File.readlines('day16.txt').map(&:chomp)

class PacketFactory

  def self.packet(packet_str)
    return if packet_str.length < 9
    packet = case packet_str.slice(3..5)
             when '100'
               LiteralPacket.new(packet_str)
             else
               if packet_str.slice(6) == "0"
                 LengthOperatorPacket.new(packet_str)
               else
                 OperatorPacket.new(packet_str)
               end
             end
             packet
  end
end

class Packet
  attr_accessor :version, :type, :packet_length, :internal_packets

  def initialize(packet_str)
    @version = packet_str.slice!(0,3).to_i(2)
    @type = packet_str.slice!(0,3).to_i(2)
    @packet_length = 6
    @internal_packets = []
  end

  def total_version
    version + @internal_packets.sum(&:total_version)
  end

  def run_operation
    run_values = internal_packets.map(&:run_operation)
    case type
    when 0
      run_values.sum
    when 1
      run_values.inject(&:*)
    when 2
      run_values.min
    when 3
      run_values.max
    when 4
      puts "NOOP"
    when 5
      run_values.first > run_values.last ? 1 : 0
    when 6
      run_values.first < run_values.last ? 1 : 0
    when 7
      run_values.first == run_values.last ? 1 : 0
    end
  end

  def to_s
    "#{@version} #{type}"
  end
end

class LiteralPacket < Packet
  attr_accessor :literal
  def initialize(packet_str)
    super(packet_str)
    @literal = decode_literal(packet_str)
  end

  # override usual run as literals have no internal packets
  def run_operation
    literal
  end

  def decode_literal(packet_str)
    literal_list = packet_str.scan(/.{5}/)
    literals = []
    literal_list.each do |literal| 
      literals << literal.slice(1..)
      break if literal.slice(0) == '0'
    end
    utilized = packet_str.slice!(0,literals.size*5)
    @packet_length += literals.size*5
    literals.join("").to_i(2)
  end

  def to_s
    "(#{super} #{literal})"
  end
end

class OperatorPacket < Packet
  attr_accessor :internal_packet_number
  def initialize(packet_str)
    super(packet_str)
    packet_str.slice!(0,1) # remove type bit
    @internal_packet_number = packet_str.slice!(0,11).to_i(2)
    @packet_length = 18
    @internal_packet_number.times do
      packet = PacketFactory.packet(packet_str)
      @packet_length += packet.packet_length
      @internal_packets << packet
    end
  end

  def to_s
    "(#{super} #{internal_packet_number} #{@internal_packets.join(", ")})"
  end

end

class LengthOperatorPacket < Packet
  attr_accessor :packet_length
  def initialize(packet_str)
    super(packet_str)
    packet_str.slice!(0,1) # remove type bit
    target_packet_length = packet_str.slice!(0,15).to_i(2)
    internal_packet_length = 0
    while(internal_packet_length < target_packet_length ) do
      packet = PacketFactory.packet(packet_str)
      break if packet.nil?
      internal_packet_length += packet.packet_length
      @internal_packets << packet
    end
    @packet_length = 22 + target_packet_length
  end

  def to_s
    "(#{super} #{packet_length} #{@internal_packets.join(", ")})"
  end

end
line = data.first
binary = line.hex.to_s(2).rjust(line.size*4, '0')
# puts binary
packet = PacketFactory.packet(binary)
# puts packet
# puts packet.total_version

puts packet.run_operation

# 100 010 1 00000000001 001 010 1 00000000001 101 010 0 000000000001011 110 100 01111000