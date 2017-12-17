class Spinlock
  attr_reader :step
  def initialize(step)
    @step = step
  end

  def run(iterations: 10, debug: false)
    pos = 0
    buf = [0]
    iterations.times do |i|
      if debug && i % 100_000 == 0
        print "\r#{i}"
      end
      pos = (step+pos) % (i+1)
      buf.insert(pos+1, i+1)
      pos += 1
    end
    buf[pos+1]
  end

  def run2(iterations: 50_000_000, debug: false)
    pos = 0
    second_position = -1
    iterations.times do |i|
      if debug && i % 1_000_000 == 0
        print "\rpos: i: #{i} pos: #{pos}, val: #{second_position}"
      end
      pos = (step + pos) % (i + 1) + 1
      if pos == 1
        second_position = i
      end
    end
    second_position
  end
end

puts "Part 1: " + Spinlock.new(366).run(iterations: 2017).to_s
puts
puts "Part 2: " + Spinlock.new(366).run2(iterations: 50_000_000).to_s
