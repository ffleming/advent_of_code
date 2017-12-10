require 'pry-byebug'
class Condition
  CONDITION_REGEX = /(?<register>\w+) (?<operation>(\<=|==|\>=|\<|\>|!=)) (?<value>[\-0-9]+)/
  attr_reader :register, :operation, :value
  def self.from(string)
    match = string.match(CONDITION_REGEX)
    new(register: match['register'],
        operation: match['operation'],
        value: match['value'].to_i
    )
  end

  def initialize(register: , operation: , value: )
    raise "Needs reg" if register.nil?
    raise "Needs op" if operation.nil?
    raise "Needs value" if value.nil?
    @register = register
    @operation = operation
    @value = value
  end
end

class Instruction
  attr_reader :register, :operation, :amount, :condition
  def initialize(register: , operation: , amount: , condition: )
    raise "Needs register" if register.nil?
    raise "Needs op" if operation.nil?
    raise "Needs amount" if amount.nil?
    raise "Needs condition" if condition.nil?
    @register = register
    @operation = operation
    @amount = amount.to_i
    @condition = condition
  end
end

class RegisterBank
  LINE_REGEX = /(?<register>\w+) (?<operation>inc|dec) (?<amount>[\-0-9]+) if (?<condition>.+)/
  attr_reader :registers, :instructions, :runtime_maximum
  def initialize(filename)
    @registers = {}
    @instructions = []
    @runtime_maximum = 0
    match = nil
    File.foreach(filename) do |line|
      match = line.match(LINE_REGEX)
      begin
      ins = Instruction.new(
        register: match['register'],
        operation: match['operation'],
        amount: match['amount'],
        condition: Condition.from(match['condition'])
      )
      rescue => e
        binding.pry
      end
      @instructions << ins
    end
  end

  def run
    instructions.each do |ins|
      create_registers_for(ins)
      execute(ins)
    end
    self
  end

  def create_registers_for(ins)
    regs = [ins.register, ins.condition.register]
    regs.each do |reg|
      @registers[reg] ||= 0
    end
  end

  def execute(ins)
    op = case ins.operation
         when 'inc'
           '+'
         when 'dec'
           '-'
         else
           raise "Don't know what to do with #{ins.operation}"
         end
    if @registers[ins.condition.register].send(ins.condition.operation, ins.condition.value)
      @registers[ins.register] = @registers[ins.register].send(op, ins.amount)
    end
    if op == '+' && @registers[ins.register] > @runtime_maximum
      @runtime_maximum = [@runtime_maximum, @registers[ins.register]].max
    end
  end

  def max_register
    @registers.max_by {|_,v| v }.last
  end
end

bank = RegisterBank.new("08.txt").run
puts "Post-run maximum: #{bank.max_register}"
puts "Runtime maximum: #{bank.runtime_maximum}"
