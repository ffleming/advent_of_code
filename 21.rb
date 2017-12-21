require 'pry-byebug'
require 'matrix'

class Rule
  attr_reader :input, :output, :to_h
  def self.from(str)
    input, output = str.split(" => ", 2).map do |rule|
      rule.split('/').map do |line|
       line.chars.map {|c| c == '#'}
      end
    end
    new(input, output)
  end

  def initialize(input, output)
    @input = input
    @output = output
    @to_h = build_lookup
  end

  def alterations
      [
        input,
        hflip(input), vflip(input),
        rrot(input), lrot(input),
        hflip(rrot(input)), hflip(lrot(input))
      ]
  end

  def build_lookup
    alterations.each_with_object({}) { |inp, memo| memo[Matrix[*inp]] = Matrix[*output] }
  end

  def lrot(inp)
    rrot(rrot(rrot(inp)))
  end

  def rrot(inp)
    inp.transpose.map {|row| row.reverse }
  end

  def hflip(inp)
    inp.map {|row| row.reverse }
  end

  def vflip(inp)
    inp.reverse
  end
end

class Art
  attr_reader :debug

  def self.test
    rules = ['../.# => ##./#../...', '.#./..#/### => #..#/..../..../#..#'].map {|s| Rule.from(s) }
    art = new(rules: rules)
    ret = art.run(2)
    puts ret.flatten.count(true)
  end

  def self.run(ticks = 18)
    rules = File.read("21.txt").split("\n").map {|s| Rule.from(s)}
    art = new(rules: rules)
    art.run(ticks).to_a.flatten.count(true)
  end

  def initialize(rules: , debug: false)
    @debug = debug
    @lookup = rules.reduce({}) do |acc, rule|
      acc.merge(rule.to_h)
    end
    @initial = Matrix[
      [false, true, false],
      [false, false, true],
      [true, true, true]
    ]
  end

  def lookup(key)
    @lookup.fetch(key)
  end

  def enhance(input)
    chunk_size = input.row_count.even? ? 2 : 3
    num_chunks = input.row_count / chunk_size
    matrix_arr = (0...num_chunks).map do |i|
      (0...num_chunks).map do |j|
        i_offset = i * chunk_size
        j_offset = j * chunk_size
        cell = input.minor(
          i_offset...(i_offset + chunk_size),
          j_offset...(j_offset + chunk_size)
        )
        lookup(cell)
      end
    end
    compose(matrix_arr)
  end

  def compose(array_of_matrices)
    rows = array_of_matrices.map do |row|
      matrices = row.map {|m| Matrix[*m] }
      Matrix.hstack(*matrices)
    end
    Matrix.vstack(*rows)
  end

  def run(ticks)
    input = @initial
    if debug
      print "\e[H\e[2J"
      puts output(input)
    end
    ticks.times do
      input = enhance(input)
      if debug
        print "\e[H\e[2J"
        puts output(input)
        sleep 0.5
      end
    end
    input
  end

  def output(inp)
    inp.map do |row|
      row.map do |bool|
        bool ? "\u2588" : " "
      end.join
    end.join("\n")
  end
end

puts "Part 1: #{Art.run(5)}"
puts "Part 2: #{Art.run(18)}"
