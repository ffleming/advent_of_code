require 'pry-byebug'
class Parser
  attr_accessor :stream, :groups, :score, :garbage_count, :debug
  CANCEL = '!'
  GARBAGE_BEGIN = '<'
  GARBAGE_END = '>'
  GROUP_BEGIN = '{'
  GROUP_END = '}'
  def initialize(filename, degub: false)
    @stream = File.read(filename)
    @groups = []
    @score = 0
    @garbage_count = 0
    @debug = debug
    process!
  end

  def process!
    garbage = false
    level = 1
    i = 0
    while i < (stream.length)
      c = stream[i]
      if debug
        puts '-' * 20
        puts "i: #{i}"
        puts "c: #{c}"
        puts "Garbage: #{garbage}"
        puts "Level #{level}"
        puts "Score #{score}"
      end
      if garbage
        case c
        when CANCEL
          i += 1
        when GARBAGE_END
          garbage = false
        else
          @garbage_count += 1
        end
      else # garbage is false
        case c
        when GARBAGE_BEGIN
          garbage = true
        when GROUP_BEGIN
          @score += level
          level += 1
        when GROUP_END
          level -= 1
        end
      end
      i += 1
    end
  end
end

parser = Parser.new('09.txt')
puts "Final score: #{parser.score}"
puts "Garbage count: #{parser.garbage_count}"
