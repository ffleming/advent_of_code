require 'pry-byebug'
class Vector3
  attr_accessor :x, :y, :z
  def initialize(x,y,z)
    @x = x
    @y = y
    @z = z
  end
end
class Particle
  attr_reader :pos, :vel, :acc, :name
  def initialize(pos, vel, acc, name: nil)
    @pos = pos
    @vel = vel
    @acc = acc
    @name = name
  end

  def distance_after(ticks)
    new_x = pos.x + (vel.x * ticks) + ((acc.x * ticks**2) / 2)
    new_y = pos.y + (vel.y * ticks) + ((acc.y * ticks**2) / 2)
    new_z = pos.z + (vel.z * ticks) + ((acc.z * ticks**2) / 2)
    p = Vector3.new(new_x, new_y, new_z)
    p.x.abs + p.y.abs + p.z.abs
  end

  def tick
    vel.x += acc.x
    vel.y += acc.y
    vel.z += acc.z
    pos.x += vel.x
    pos.y += vel.y
    pos.z += vel.z
    self
  end

  def eql?(other)
    pos.x == other.pos.x &&
      pos.y == other.pos.y &&
      pos.z == other.pos.z
  end

  def hash
    "x #{pos.x} y #{pos.y} z #{pos.z}".hash
  end
end

class Particles
  attr_reader :particles
  def initialize(str)
    @particles = str.split("\n").each_with_object([]).with_index do |(line, memo), i|
      line.match(/p=<(.+)>, v=<(.+)>, a=<(.+)>/)
      pos = $1.strip.split(",", 3).map(&:to_i)
      vel = $2.strip.split(",", 3).map(&:to_i)
      acc = $3.strip.split(",", 3).map(&:to_i)
      memo << Particle.new(
        Vector3.new(*pos),
        Vector3.new(*vel),
        Vector3.new(*acc),
        name: i
      )
    end
  end

  def size
    @particles.size
  end
  alias_method :count, :size

  def closest_after(ticks)
    particles.map do |p|
      [p, p.distance_after(ticks)]
    end.sort do |a, b|
      a[1] <=> b[1]
    end.first[0]
  end

  def resolve_collisions
    t = 0
    last = particles.count
    loop do
      @particles.each {|p| p.tick }
      @particles = @particles.group_by do |p|
        pos = p.pos
        [pos.x, pos.y, pos.z]
      end.select do |_,v|
        v.size == 1
      end.values.flatten
      t += 1
      if particles.count < last
        t = 0
        last = particles.count
      end
      break if t > 100
    end
    self
  end
end

TEST = <<-EOS
p=<3,0,0>, v=<2,0,0>, a=<-1,0,0>
p=<4,0,0>, v=<0,0,0>, a=<-2,0,0>
EOS
input = if ARGV.any? {|a| a.include?('t') }
          TEST
        else
          File.read("20.txt")
        end
puts "Part 1: #{Particles.new(input).closest_after(10_000_000).name}"
puts "Part 2: #{Particles.new(input).resolve_collisions.count}"
