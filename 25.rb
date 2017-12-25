class TuringTape
  attr_reader :checksum_after, :tape, :state, :position, :debug
  def initialize(checksum_after: 12134527, debug: true)
    @checksum_after = checksum_after
    @state = :a
    # Use /all the memory in the world/ to avoid growth logic
    @tape = Array.new(checksum_after * 2 + 1) { 0 }
    @position = checksum_after
    @debug = debug
  end

  def run
    checksum_after.times do |t|
      step
      if debug
        print "\r#{t}" if t % 50_000 == 0
      end
    end
    self
  end

  STATES = {
    a: :state_a,
    b: :state_b,
    c: :state_c,
    d: :state_d,
    e: :state_e,
    f: :state_f,
  }
  def step
    meth = STATES[state]
    raise "Unknown state #{state}" if meth.nil?
    send(meth)
  end

  def current
    tape[position]
  end

  def write(val)
    @tape[position] = val
  end

  def move_right
    @position += 1
  end

  def move_left
    @position -= 1
  end

  def checksum
    @tape.count(1)
  end

  def state_a
    if current == 0
      write(1)
      move_right
      @state = :b
    elsif current == 1
      write(0)
      move_left
      @state = :c
    else
      raise "Got #{current}"
    end
  end

  def state_b
    if current == 0
      write(1)
      move_left
      @state = :a
    elsif current == 1
      write(1)
      move_right
      @state = :c
    else
      raise "Got #{current}"
    end
  end

  def state_c
    if current == 0
      write(1)
      move_right
      @state = :a
    elsif current == 1
      write(0)
      move_left
      @state = :d
    else
      raise "Got #{current}"
    end
  end

  def state_d
    if current == 0
      write(1)
      move_left
      @state = :e
    elsif current == 1
      write(1)
      move_left
      @state = :c
    else
      raise "Got #{current}"
    end
  end

  def state_e
    if current == 0
      write(1)
      move_right
      @state = :f
    elsif current == 1
      write(1)
      move_right
      @state = :a
    else
      raise "Got #{current}"
    end
  end

  def state_f
    if current == 0
      write(1)
      move_right
      @state = :a
    elsif current == 1
      write(1)
      move_right
      @state = :e
    else
      raise "Got #{current}"
    end
  end
end

tape = TuringTape.new.run
puts
puts tape.checksum
