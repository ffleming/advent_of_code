require 'pry-byebug'

class Integer
  def to_hex_string
    ret = to_s(16)
    if ret.length.odd?
      ret = "0#{ret}"
    end
    ret
  end
end

class Array
  def reverse_subarray!(start, len)
    fin = start + len
    if fin > (length - 1) # wrapping
      first_part = self[start..-1]
      second_part = self[0...(len - first_part.length)]
      rev = (first_part + second_part).reverse
      self[start..-1] = rev[0...first_part.length]
      self[0...second_part.length] = rev[(first_part.length)..-1]
    else # not wrapping
      rev = self[start...fin].reverse
      self[start...fin] = rev
    end
    self
  end
end

class KnotAlgo
  attr_reader :debug, :list
  def initialize(filename, debug: false)
    range_end = if filename == 'test.txt'
            4
          else
            255
          end
    @list = (0..range_end).to_a
    @inputs = File.read(filename).split(',').map(&:to_i)
    @position = 0
    @skip_size = 0
    @debug = debug
  end

  def run
    puts self.to_s if debug
    @inputs.each.with_index(1) do |input, i|
      process_one(input)
      puts self.to_s if debug
    end
    self
  end

  def process_one(length)
    reverse(length)
    @position = (@position + length + @skip_size ) % @list.length
    @skip_size += 1
  end

  def reverse(length)
    @list.reverse_subarray!(@position, length)
  end

  def solution
    @list[0] * @list[1]
  end

  def to_s
    cur = @position % @list.length
      @list.map.with_index do |el, i|
        if i == cur
          "[#{el}]"
        else
          "#{el}"
        end
      end.join(", ")
  end
end

class KnotHash
  attr_reader :debug, :list
  def initialize(str)
    @list = (0..255).to_a
    @inputs = str.strip.bytes + [17, 31, 73, 47, 23]
    @position = 0
    @skip_size = 0
    @debug = debug
  end

  def run
    64.times do
      @inputs.each do |input|
        process_one(input)
      end
    end
    self
  end

  def process_one(length)
    @list.reverse_subarray!(@position, length)
    @position = (@position + length + @skip_size ) % @list.length
    @skip_size += 1
  end

  def to_s
    cur = @position % @list.length
      @list.map.with_index do |el, i|
        if i == cur
          "[#{el}]"
        else
          "#{el}"
        end
      end.join(", ")
  end

  def dense_hash
    @list.each_slice(16).with_object([]) do |arr, memo|
      memo << arr.reduce(&:^)
    end
  end

  def hash
    dense_hash.map(&:to_hex_string).join
  end
end

# puts "Part 1: #{KnotAlgo.new('10.txt').run.solution}"
# k = KnotHash.new(File.read("10.txt")).run
# puts "Part 2: '#{k.hash}'"
