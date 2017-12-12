require 'pry-byebug'
class HexGrid
  attr_reader :debug, :longest_distance
  alias_method :debug?, :debug
  def initialize(str, debug: )
    @debug = debug
    @inputs = str.strip.split(",").map(&:to_sym)
    @longest_distance = 0
    @distances = {}
  end

  def target
    return @target if defined? @target
    x = 0.0
    y = 0.0
    @inputs.each do |direction|
      case direction
      when :nw
        x -= 1.0
        y += 0.5
      when :n
        y += 1.0
      when :ne
        y += 0.5
        x += 1.0
      when :se
        y -= 0.5
        x += 1.0
      when :s
        y -= 1.0
      when :sw
        y -= 0.5
        x -= 1.0
      end
      # this kills perf
      # ruby 11.rb  1.73s user 0.20s system 90% cpu 2.142 total
      # memoizing distances helps a bit but still
      # ruby 11.rb  1.53s user 0.13s system 97% cpu 1.700 total
      dist = if @distances[ [x,y] ]
               @distances[ [x,y] ]
             else
               distance_for(x, y)
             end
      @distances[ [x,y] ] = dist
      if dist > @longest_distance
        @longest_distance = dist
      end
    end
    @target = [x, y]
  end

  def path_for(target_x, target_y)
    x = 0.0
    y = 0.0
    n = 0
    _path = []
    while x != target_x || y != target_y
      n += 1
      if x < target_x && y < target_y
        _path << :ne
        x += 1.0
        y += 0.5
      elsif x > target_x && y < target_y
        _path << :nw
        x -= 1.0
        y += 0.5
      elsif x > target_x && y > target_y
        _path << :sw
        x -= 1.0
        y -= 0.5
      elsif x < target_x && y > target_y
        _path << :se
        x += 1.0
        y -= 0.5
      elsif x == target_x && y > target_y
        _path << :s
        y -= 1.0
      elsif x == target_x && y < target_y
        _path << :n
        y += 1.0
      elsif y == target_y && x < target_x
        _path << :se
        x += 1.0
        y -= 0.5
      elsif y == target_y && x > target_x
        _path << :sw
        x -= 1.0
        y -= 0.5
      else
        raise "OOPS"
      end
      puts "added #{_path.last} x: #{x} y: #{y}" if debug?
    end
    puts _path.join(', ') if debug?
    _path
  end

  def distance_for(x, y)
    path_for(x, y).length
  end
end

def test(str, distance)
  h = HexGrid.new(str)
  if h.distance != distance
    raise "#{str}: expected #{distance}, got #{h.distance}"
  end
end
# test("ne,ne,ne", 3)
# test("ne,ne,sw,sw", 0)
# test("ne,ne,s,s", 2)
# test("se,sw,se,sw,sw", 3)

sol = HexGrid.new(File.read('11.txt'), debug: false)
puts "Distance is #{sol.distance_for(*sol.target)}"
puts "Longest distance is #{sol.longest_distance}"
