require 'pry-byebug'
require_relative './10.rb'
class String
  def to_bin_string
    scan(/../).map { |s| s.hex }.map {|s| s.to_s(2).rjust(8, '0')}.join
  end
end

class Node
  attr_reader :row, :col
  attr_accessor :neighbors, :value
  def initialize(row: , col: , value: )
    @row = row
    @col = col
    @value = value
    @neighbors = []
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
        nodes[row][col] = Node.new(row: row, col: col, value: val)
      end
    end
    nodes.each do |row|
      row.each do |node|
        node.neighbors = neighbors_for(node.row, node.col).map do |neighbor_row, neighbor_col|
          nodes[neighbor_row][neighbor_col]
        end
      end
    end
    _regions = 0
    nodes.each do |row|
      row.each do |node|
        if node.value == '#'
          _regions += 1
          paint(node, _regions)
        end
      end
    end
    _regions
  end

  def paint(node, val)
    node.value = val.to_s
    node.neighbors.each do |n|
      next if n.value != '#'
      paint(n, val)
    end
  end
end

d = Defrag.new('stpzcrnm')
puts "Part 1: #{d.used}"
puts "Part 2: #{d.regions}"
