# It didn't occur to me to keep track of direction as relative from position and then use matrix math to find
# next coords.  ¯\_(ツ)_/¯
require 'pry-byebug'
class Follower
  CHAR = 0
  VISITED = 1
  attr_reader :maze, :position, :path, :debug, :heading, :steps

  def initialize(str, debug: false)
    start_col = nil
    @maze = str.split("\n").map.with_index do |line, row|
      line.split(//).map.with_index do |char, col|
        if row == 0 && char == '|'
          start_col = col
        end
        [char, false]
      end
    end
    @debug = debug
    @heading = :south
    @position = [0, start_col]
    @path = ''
    @steps = 0
  end

  def current_neighbors
    row = position[0]
    col = position[1]
    neighbors = []
    neighbors << [row - 1, col] if row > 0
    neighbors << [row + 1, col] if row < maze.length - 1
    neighbors << [row, col - 1] if col > 0
    neighbors << [row, col + 1] if col < maze.first.length - 1

    neighbors.select do |r, c|
      cell = maze[r][c]
      cell[CHAR] != ' '
    end
  end

  def next_cell_and_heading
    row = position[0]
    col = position[1]
    potential = current_neighbors
    according_to_heading = potential.select do |r, c|
      case heading
      when :north
        c == col && r < row
      when :south
        c == col && r > row
      when :east
        r == row && c > col
      when :west
        r == row && c < col
      else
        raise "Unknown heading #{heading}"
      end
    end

    next_coords = if according_to_heading.empty?
                    # We need to turn
                    potential.select do |r, c|
                      cell = maze[r][c]
                      cell[VISITED] == false && (
                        cell[CHAR] == turned_path || LETTERS.include?(cell[CHAR])
                      )
                    end
                  else
                    # We can go straight
                    according_to_heading
                  end
    next_coords.flatten!

    if next_coords.empty?
      return [:done, :done] # hacky a f
    elsif next_coords.length != 2
      raise "D:"
    end
    row_delta = row - next_coords[0]
    col_delta = col - next_coords[1]
    new_heading = if row_delta == 0
                     col_delta < 0 ? :east : :west
                  elsif col_delta == 0
                    row_delta < 0 ? :south : :north
                  else
                    raise "Oops"
                  end

    [next_coords, new_heading]
  end

  def turned_path
    if %i(north south).include?(heading)
      '-'
    else
      '|'
    end
  end

  def current_char
    maze[ position[0] ][ position[1] ][ CHAR ]
  end

  def visit_current
    maze[ position[0] ] [position[1] ][VISITED] = true
  end

  LETTERS = ('A'..'Z').to_a.freeze
  def follow
    loop do
      if debug
        print "\r(#{position.join(',')}) #{current_char}, heading: #{heading}, path: #{path} #{' ' * 20}"
      end
      if LETTERS.include?(current_char)
        @path << current_char
      end
      visit_current
      @position, @heading = next_cell_and_heading
      @steps += 1
      return self if @heading == :done
    end
  end

  def output
    maze.map.with_index do |row, r|
      row.map.with_index do |col, c|
        if r == position[0] && c == position[1]
          '*'
        else
          col[CHAR]
        end
      end.join
    end.join("\n")
  end
end

TEST = <<-EOS
     |          
     |  +--+    
     A  |  C    
 F---|----E|--+ 
     |  |  |  D 
     +B-+  +--+ 
EOS
input = File.read('19.txt')
# input = TEST
follower = Follower.new(input, debug: false).follow
puts
puts "Part 1: #{follower.path}"
puts "Part 2: #{follower.steps}"
