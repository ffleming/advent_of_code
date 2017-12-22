require 'pry-byebug'
class Infector
  NORTH = [-1,0].freeze
  SOUTH = [1,0].freeze
  EAST = [0,-1].freeze
  WEST = [0,1].freeze

  attr_reader :board, :position, :heading, :infections, :debug, :part
  def initialize(str, debug: false, part: 2)
    @board = str.split("\n").map {|l| l.split(//)}
    @heading = NORTH
    @position = [ (@board.length - 1 ) / 2,
            (@board.first.length - 1) /2 ]
    @infections = 0
    @debug = debug
    @part = part
  end

  HEADING_CHARS = { EAST => '>', WEST => '<', SOUTH => 'v', NORTH => '^'}.freeze
  def to_s
    board.each_with_index.with_object('') do |(r_values, row), memo|
      r_values.each_index do |col|
        memo << if position[0] == row && position[1] == col
                 HEADING_CHARS.fetch(heading)
               else
                 board[row][col]
               end
      end
      memo << "\n"
    end
  end

  def grow_board
    rows = board.length
    cols = board.first.length
    case heading
    when WEST
      if position[1] == cols - 1
        board.each { |arr| arr << '.' }
      end
    when EAST
      if position[1] == 0
        board.each { |arr| arr.insert(0, '.') }
        @position[1] += 1
      end
    when SOUTH
      if position[0] == rows - 1
        @board << Array.new(cols, '.')
      end
    when NORTH
      if position[0] == 0
        @board.insert(0, Array.new(cols, '.'))
        @position[0] += 1
      end
    end
  end

  def move_forward
    grow_board
    @position = [
      position[0] + heading[0],
      position[1] + heading[1]
    ]
  end

  def tick
    if infected?
      turn_right
    else
      turn_left
    end
    if clean?
      self.current_node = '#'
      @infections += 1
    else
      self.current_node = '.'
    end
    move_forward
  end

  def tick_2
    if clean?
      turn_left
    elsif weakened?
      # keep going forward
    elsif infected?
      turn_right
    elsif flagged?
      turn_right
      turn_right
    end

    if clean?
      self.current_node = 'W'
    elsif weakened?
      self.current_node = '#'
      @infections += 1
    elsif infected?
      self.current_node = 'F'
    elsif flagged?
      self.current_node = '.'
    end

    move_forward
  end

  def current_node
    board[position[0]][position[1]]
  end

  def current_node=(obj)
    board[position[0]][position[1]] = obj
  end

  def infected?
    current_node == '#'
  end

  def clean?
    current_node == '.'
  end

  def weakened?
    current_node == 'W'
  end

  def flagged?
    current_node == 'F'
  end

  def run(ticks)
    if debug
      puts self.to_s
      puts
    end
    ticks.times do |t|
      if part == 1
        tick
      else
        tick_2
      end
      if debug
        puts self.to_s
        puts
      end
    end
    self
  end

  def turn_right
    @heading = [ heading[1], -heading[0] ]
  end

  def turn_left
    @heading = [-heading[1], heading[0]]
  end
end
TEST = <<-EOS
..#
#..
...
EOS
input = ARGV.any? {|a| a.include?('t') } ? TEST : File.read('22.txt')

inf = Infector.new(input, debug: false, part: 1)
puts "Part 1: #{inf.run(10_000).infections}"
inf = Infector.new(input, debug: false, part: 2)
puts "Part 2: #{inf.run(10_000_000).infections}"
