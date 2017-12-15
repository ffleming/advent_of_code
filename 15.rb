require 'pry-byebug'
class Fifteen
  A_FACTOR = 16807
  B_FACTOR = 48271
  DIV = 2147483647
  def initialize(a: , b: )
    @a_prev = a
    @b_prev = b
  end

  def part1(n)
    dup = 0
    a_prev = @a_prev
    b_prev = @b_prev
    n.times do |i|
      a = (a_prev * A_FACTOR) % DIV
      b = (b_prev * B_FACTOR) % DIV
      a_prev = a
      b_prev = b
      if a & 0xFFFF == b & 0xFFFF
        dup += 1
      end
    end
    dup
  end

  def part2(n)
    a_prev = @a_prev
    b_prev = @b_prev

    a_judge = 0
    arr_a = []
    while a_judge <= n
      a = (a_prev * A_FACTOR) % DIV
      a_prev = a
      if a % 4 == 0
        arr_a << (a & 0xFFFF)
        a_judge += 1
      end
    end

    b_judge = 0
    arr_b = []
    while b_judge <= n
      b = (b_prev * B_FACTOR) % DIV
      b_prev = b
      if b % 8 == 0
        arr_b << (b & 0xFFFF)
        b_judge += 1
      end
    end

    arr_a.zip(arr_b).select do |a, b|
      a == b
    end.count
  end
end

# puts Fifteen.new(a: 65,  b: 8921).part1(40_000_000)
puts "Part 1: " + Fifteen.new(a: 783,  b: 325).part1(40_000_000).to_s
# puts Fifteen.new(a: 65,  b: 8921).part2(5_000_000)
puts "Part 2: " + Fifteen.new(a: 783,  b: 325).part2(5_000_000).to_s
