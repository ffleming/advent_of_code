require 'pry-byebug'
class Infector
  attr_reader :board, :position, :heading, :infections, :debug, :part
  def initialize(str, debug: false, part: 2)
    @board = str.split("\n").map {|l| l.split(//)}
    @heading = [-1, 0] # north
    @position = [ (@board.length - 1 ) / 2,
            (@board.first.length - 1) /2 ]
    @infections = 0
    @debug = debug
    @part = part
  end

  def to_s
    ret = ''
    board.each_with_index do |r_values, row|
      r_values.each_index do |col|
        char = if @position[0] == row && position[1] == col
                 case heading
                 when [0, 1]
                   '>'
                 when [0, -1]
                   '<'
                 when [1, 0]
                   'v'
                 when [-1, 0]
                   '^'
                 end
               else
                 board[row][col]
               end
        ret << char
      end
      ret << "\n"
    end
    ret
  end

  def grow_board
    rows = board.length
    cols = board.first.length
    case heading
    when [0, 1] #east
      if position[1] == cols - 1
        board.each { |arr| arr << '.' }
      end
    when [0, -1] #west
      if position[1] == 0
        board.each { |arr| arr.insert(0, '.') }
        @position[1] += 1
      end
    when [1, 0] #south
      if position[0] == rows - 1
        @board << Array.new(cols, '.')
      end
    when [-1, 0] # north
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
      board[position[0]][position[1]] = '#'
      @infections += 1
    else
      board[position[0]][position[1]] = '.'
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
      board[position[0]][position[1]] = 'W'
    elsif weakened?
      board[position[0]][position[1]] = '#'
      @infections += 1
    elsif infected?
      board[position[0]][position[1]] = 'F'
    elsif flagged?
      board[position[0]][position[1]] = '.'
    end

    move_forward
  end

  def current_node
    board[position[0]][position[1]]
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
