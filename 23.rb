require 'pry-byebug'
require 'prime'
class Instruction
  attr_reader :type, :x, :y
  def initialize(str)
    case str
    when /set (\w+) (-?\w+)/
      @type = :set
      @x = $1
      @y = $2
    when /sub (\w+) (-?\w+)/
      @type = :sub
      @x = $1
      @y = $2
    when /mul (\w+) (-?\w+)/
      @type = :mul
      @x = $1
      @y = $2
    when /jnz (-?\w+) (-?\w+)/
      @type = :jnz
      @x = $1
      @y = $2
    else
      raise "Don't understand `#{str}`"
    end
    @x = @x.strip
    @y = @y.strip unless @y.nil?
    fix_types!
  end

  def fix_types!
    if %i(set sub mul).include?(type) && @x =~ /\d+/
      raise "X can't be an int"
    end
    if @x =~ /-?\d+/
      @x = @x.to_i
    end
    if @y =~ /-?\d+/
      @y = @y.to_i
    end
  end
end

class CPU
  attr_reader :instructions, :registers, :ins_pointer, :num_muls, :part, :dead
  def initialize(str, part: 2)
    @instructions = str.split("\n").
                      map do |ins|
                        Instruction.new(ins)
                      end
    @ins_pointer = 0
    @num_muls = 0
    @registers = {}.tap do |h|
      ('a'..'h').each  {|c| h[c] = 0 }
    end
    @part = part
    if @part == 2
      @registers['a'] = 1
    end
    @dead = false
  end

  def value_of(obj)
    case obj
    when Integer
      obj
    when String
      registers.fetch(obj)
    end
  end

  def process(ins)
    case ins.type
    when :set
      registers[ins.x] = value_of(ins.y)
    when :sub
      registers[ins.x] = registers[ins.x] - value_of(ins.y)
    when :mul
      registers[ins.x] = registers[ins.x] * value_of(ins.y)
      @num_muls += 1
    when :jnz
      if value_of(ins.x) != 0
        @ins_pointer += value_of(ins.y)
      else
        @ins_pointer += 1
      end
    else
      raise "Can't process #{ins.type}"
    end
  end

  def tick
    if ins_pointer < 0 || ins_pointer >= instructions.length
      @dead = true
      return
    end
    ins = instructions[ins_pointer]
    process(ins)
    @ins_pointer += 1 if ins.type != :jnz
  end

  def run
    @ins_pointer = 0
    while dead == false
      tick
    end
    self
  end

  def to_s
    "CPU #{sends}, waiting: #{waiting} dead: #{dead}"
  end
end


input = File.read('23.txt')
puts "Part 1: #{CPU.new(input, part: 1).run.num_muls}"

b = 106500
c = 123500
answer = 0
(b..c).step(17).each do |n|
  answer += 1 if !Prime.prime?(n)
end

puts "Part 2: #{answer}"
