require 'pry-byebug'
require_relative './10.rb'
class String
  def to_bin_string
    scan(/../).map { |s| s.hex }.map {|s| s.to_s(2).rjust(8, '0')}.join
  end
end

class Defrag
  attr_reader :memory
  def initialize(str)
    @memory = (0..127).map.with_object([]) do |n, memo|
      hash = KnotHash.new("#{str}-#{n}").run.hash
      memo << hash.to_bin_string
    end
  end

  def used
    @memory.map {|bin_str| bin_str.count('1')}.sum
  end

  def neighbors_for(row, col)
    neighbors = []
    neighbors << [row - 1, col] if row > 0
    neighbors << [row + 1, col] if row < 127
    neighbors << [row, col - 1] if col > 0
    neighbors << [row, col + 1] if col < 127
    neighbors
  end

  def regions
    nodes = Array.new(128) { Array.new(128)}
    (0..127).each do |row|
      (0..127).each do |col|
        val = memory[row][col] == '1' ? '#' : '.'
        nodes[row][col] = val
      end
    end
    _regions = 0
    nodes.each_with_index do |arr, row|
      arr.each_index do |col|
        if nodes[row][col] == '#'
          _regions += 1
          nodes = paint(row,col, _regions, nodes)
        end
      end
    end
    _regions
  end

  def paint(row, col, val, nodes)
    nodes[row][col] = val
    neighbors_for(row, col).each do |r, c|
      next if nodes[r][c] != '#'
      nodes = paint(r, c, val, nodes)
    end
    nodes
  end
end

d = Defrag.new('stpzcrnm')
puts "Part 1: #{d.used}"
puts "Part 2: #{d.regions}"
