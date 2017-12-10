require 'pry-byebug'
class Walker
  attr_accessor :matrix, :size, :origin, :dir, :current, :target
  def initialize(size: 1000, target: 347991)
    @size = size
    @target = target
    @matrix = Array.new(size) { Array.new(size, 0) }
    @origin = [size / 2, size / 2]
    @matrix[size / 2][size / 2] = 1
    @dir = nil
    @current = nil
  end

  def walk!
    @current = origin
    @dir = next_dir!
    loop do
      go(dir)
      puts "went #{dir}"
      result = neighbor_sum
      write(result)
      puts "wrote #{result}"
      break if result > target
      if should_turn?
        @dir = next_dir!
      end
    end
  end

  def status
    ret = matrix.map do |row|
      row.map(&:to_s).map {|el| el.center(5, " ")}.join(" ")
    end.join("\n")
    puts ret
  end


  def go(dir)
    self.x += directions.fetch(dir)[1]
    self.y += directions.fetch(dir)[0]
  end

  def x
    current[1]
  end

  def y
    current[0]
  end

  def x=(val)
    current[1] = val
  end

  def y=(val)
    current[0] = val
  end

  NEIGHBORS = [
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, -1],
    [0, 1],
    [1, -1],
    [1, 0],
    [1, 1],
  ]
  def neighbor_sum
    ns = NEIGHBORS.map do |delta_y, delta_x|
      matrix[y + delta_y][x + delta_x]
    end
    ns.sum
  end

  def write(val)
    matrix[y][x] = val
  end

  def should_turn?
    look(peek_dir) == 0
  end

  def look(_dir)
    delta_x = directions.fetch(_dir)[1]
    delta_y = directions.fetch(_dir)[0]
    matrix[y + delta_y][x + delta_x]
  end


  def peek_dir
    arr = %i(right up left down)
    i = arr.index(dir)
    arr[(i + 1) % 4]
  end

  def next_dir!
    @_next_dir ||= 0
    ret = %i(right up left down)[@_next_dir % 4]
    @_next_dir += 1
    ret
  end

  def directions
    @directions ||= {
      right: [0, 1],
      up:  [-1, 0],
      left:  [0, -1],
      down:    [1, 0],
    }
  end
end
Walker.new.walk!
