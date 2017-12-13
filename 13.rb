require 'pry-byebug'
class Layer
  DIRECTIONS = %i(up down)
  attr_reader :scanner_position, :depth, :number, :direction
  def initialize(number: , depth: )
    @depth = depth
    @scanner_position = 1
    @direction = :down
    @number = number
    @range = Array(1..depth) + Array((depth-1).downto(2))
  end

  def switch_direction!
    @direction = @direction == :up ? :down : :up
  end

  def severity
    number * depth
  end

  def has_scanner?
    depth > 0
  end

  def tick
    return if !has_scanner?
    if depth == 1
      @scanner_position = 1
      return
    end
    case direction
    when :up
      @scanner_position -= 1
    when :down
      @scanner_position += 1
    else
      raise "WHAT IS #{direction}?"
    end
    if scanner_position == 1 && direction == :up
      @direction = :down
    end
    if scanner_position == depth && direction == :down
      @direction = :up
    end
  end

  def to_s
    depth_str = (1..depth).map {|n| n == scanner_position ? "[*]" : "[ ]" }.join(" ")
    "#{number}: #{depth_str}"
  end

  def position_at(turn, delay: 0)
    return -1 if depth == 0
    num_turns = turn + delay
    @range[num_turns % @range.length]
  end
end

class Firewall
  attr_reader :layers, :packet_position, :severity, :turn, :debug
  def initialize(str, debug: false)
    @layers = []
    @packet_position = -1
    @severity = 0
    @debug = debug
    @turn = 0
    str.split("\n").each do |line|
      layer, depth = line.split(": ", 2)
      layer = layer.to_i
      depth = depth.to_i
      add_layer(layer, depth)
    end
    add_null_layers
  end

  def run
    while @packet_position < @layers.size - 1
      tick
      @turn += 1
    end
    self
  end

  # The simulation was fun but takes too long, just math it
  def self.find_optimal(input)
    f = new(input)
    delay = 0
    loop do
      caught = f.will_be_caught_with_delay(delay)
      return delay unless caught
      delay += 1
    end
  end

  def will_be_caught_with_delay(delay)
    @layers.any? do |layer|
      if layer.depth == 0
        false
      else
        layer.position_at(layer.number, delay: delay ) == 1
      end
    end
  end

  def fast_severity
    @layers.select do |layer|
      layer.position_at(layer.number) == 1
    end.map(&:severity).sum
  end

  def move_packet
    @packet_position += 1
    if caught?(current_layer)
      @severity += (current_layer.severity)
      if debug
        puts "Got caught at layer #{current_layer.number}, severity #{current_layer.severity}, total #{@severity}"
      end
    end
  end

  def caught?(layer)
    layer.has_scanner? && layer.scanner_position == 1
  end

  def current_layer
    raise "NOT IN FIREWALL" if @packet_position == -1
    @layers[@packet_position]
  end

  def to_s
    "Packet is in layer #{@packet_position}\n" +
      @layers.map(&:to_s).join("\n")
  end

  def tick
    if debug
      puts "Picosecond #{@turn}"
      puts self
    end
    move_packet
    tick_layers
    puts self if debug
    puts "-" * 30 if debug
  end

  def tick_layers
    @layers.each {|l| l.tick}
  end

  def add_layer(layer,depth)
    @layers[layer] = Layer.new(number: layer, depth: depth)
  end

  def add_null_layers
    @layers.each_with_index do |layer, i|
      if layer.nil?
        @layers[i] = Layer.new(number: i, depth: 0)
      end
    end
  end
end

TEST = <<-EOS
0: 3
1: 2
4: 4
6: 4
EOS
input = if ARGV.any? {|a| %w(t -t --test test).include? a }
          TEST
        else
          File.read("13.txt")
        end
f = Firewall.new(input)
f.run
puts "Total severity: #{f.fast_severity}"

puts "Min delay: #{Firewall.find_optimal(input)}"
