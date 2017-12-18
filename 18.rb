require 'pry-byebug'
class Instruction
  attr_reader :type, :x, :y
  def initialize(str)
    case str
    when /snd (-?\w+)/
      @type = :snd
      @x = $1
      @y = nil
    when /set (\w+) (-?\w+)/
      @type = :set
      @x = $1
      @y = $2
    when /add (\w+) (-?\w+)/
      @type = :add
      @x = $1
      @y = $2
    when /mul (\w+) (-?\w+)/
      @type = :mul
      @x = $1
      @y = $2
    when /mod (\w+) (-?\w+)/
      @type = :mod
      @x = $1
      @y = $2
    when /rcv (-?\w+)/
      @type = :rcv
      @x = $1
      @y = nil
    when /jgz (-?\w+) (-?\w+)/
      @type = :jgz
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
    if %i(set add mul mod).include?(type) && @x =~ /\d+/
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
  attr_reader :instructions, :registers, :ins_pointer, :last_sound,
    :queue, :sends, :part, :waiting, :dead, :program_id
  attr_accessor :other
  def initialize(str, program_id: , other: nil, part: 1)
    @instructions = str.split("\n").
                      map do |ins|
                        Instruction.new(ins)
                      end
    @ins_pointer = 0
    @sends = 0
    @last_sound = nil
    @queue = []
    @other = other
    @registers = {}.tap do |h|
      ('a'..'z').each  {|c| h[c] = 0 }
    end
    @registers['p'] = program_id
    @program_id = program_id
    @part = part
    @waiting = false
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
    when :snd
      if !other.nil?
        other.queue.unshift(value_of(ins.x))
      end
      @sends += 1
      @last_sound = value_of(ins.x)
    when :set
      registers[ins.x] = value_of(ins.y)
    when :add
      registers[ins.x] = registers[ins.x] + value_of(ins.y)
    when :mul
      registers[ins.x] = registers[ins.x] * value_of(ins.y)
    when :mod
      registers[ins.x] = registers[ins.x] % value_of(ins.y)
    when :rcv
      if part == 2
        if queue.empty?
          @waiting = true
          @ins_pointer -= 1
        else
          registers[ins.x] = queue.pop
          @waiting = false
        end
      end
      if part == 1 && value_of(ins.x) != 0
        @dead = true
      end
    when :jgz
      if value_of(ins.x) > 0
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
    @ins_pointer += 1 if ins.type != :jgz
  end

  def run
    @ins_pointer = 0
    while dead == false
      tick
    end
    self
  end

  def to_s
    "CPU ##{program_id}: sends: #{sends}, last_sound #{last_sound} waiting: #{waiting} dead: #{dead}"
  end
end

class Coordinator
  attr_reader :zero, :one
  def initialize(input)
    @zero = CPU.new(input, program_id: 0, part: 2)
    @one = CPU.new(input, program_id: 1, part: 2)
    @zero.other = @one
    @one.other = @zero
  end

  def execute
    loop do
      break if (zero.waiting || zero.dead) && (one.waiting || one.dead)
      zero.tick
      one.tick
    end
    self
  end
end


TEST = <<-EOS
set a 1
add a 2
mul a a
mod a 5
snd a
set a 0
rcv a
jgz a -1
set a 1
jgz a -2
EOS
TEST2 = <<-EOS
snd 1
snd 2
snd p
rcv a
rcv b
rcv c
rcv d
EOS
input = File.read('18.txt')
puts "Part 1: #{CPU.new(input, program_id: 0, part: 1).run.last_sound}"
puts "Part 2: #{Coordinator.new(File.read('18.txt')).execute.one.sends}"
