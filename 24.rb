require 'pry-byebug'

class BridgeAnalysis
  def self.run(input)
    new(input).run
  end

  attr_reader :max_length, :max_strength, :strength_of_longest
  def initialize(input)
    @components = input.split("\n").map { |l| l.split("/").map(&:to_i) }
    @max_strength = 0
    @max_length = 0
    @strength_of_longest = 0
  end

  def run(start_with: 0)
    _run(available: @components, connection: start_with)
    self
  end

  def reset!
    @max_length = 0
    @max_strength = 0
    @strength_of_longest = 0
  end

  private

  def _run(available: , connection: , strength: 0, length: 0 )
    if strength > max_strength
      @max_strength = strength
    end
    if length >= max_length
      @max_length = length
      if strength > strength_of_longest
        @strength_of_longest = strength
      end
    end
    possible = available.select { |p| p.include?(connection) }
    possible.each do |piece|
      new_available = available.reject {|e| e == piece}
      next_connection = if piece[0] == connection
                          piece[1]
                        else
                          piece[0]
                        end
      _run(available: new_available,
           connection: next_connection,
           strength: strength + piece[0] + piece[1],
           length: length + 1)
    end
  end
end

TEST = <<-EOS
0/2
2/2
2/3
3/4
3/5
0/1
10/1
9/10
EOS

input = if ARGV.any? {|a| a.downcase.include?('t') }
          TEST
        else
          File.read("24.txt")
        end

a = BridgeAnalysis.new(input).run
puts "Part 1 #{a.max_strength}"
puts "Part 2 #{a.strength_of_longest}"
