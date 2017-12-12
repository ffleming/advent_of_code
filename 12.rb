require 'pry-byebug'
class Node
  attr_accessor :name, :neighbors, :visited
  def initialize(name: , neighbors: )
    @name = name
    @neighbors = neighbors
    @visited = false
  end
end

class Graph
  attr_reader :nodes, :debug
  def initialize(str, debug: true)
    # could use array since these are just dense int keys but let's be flexible
    @nodes = {}
    @debug = debug
    str.split("\n").each do |line|
      node, neighbors = line.split(" <-> ", 2)
      node = node.to_i
      neighbors = neighbors.split(",").map(&:to_i)
      add_node!(node, neighbors)
    end
  end

  def add_node!(num, neighbors)
    neighbors.each do |edge|
      if @nodes[edge].nil?
        @nodes[edge] = Node.new(name: edge, neighbors: [])
      end
    end
    if @nodes[num].nil?
      @nodes[num] = Node.new(name: num,
                             neighbors: neighbors.map {|e| @nodes.fetch(e) } )
    else
      n = @nodes[num]
      neighbors.each do |edge|
        n.neighbors << @nodes[edge]
      end
    end
  end

  def clear_visited!
    @nodes.each do |_, node|
      node.visited = false
    end
  end

  def groups
    clear_visited!
    # could use a hash, delete in the visit block, etc. to avoid iterating through @nodes. but @nodes is
    # small so it's fine
    @nodes.each_with_object([]) do |(_, node), memo|
      next if node.visited
      group = []
      visit(node) do |n|
        group << n
      end
      puts "Found a group with #{group.size} members" if debug
      memo << group
    end
  end

  def visit(root)
    queue = [root]
    until queue.empty?
      cur = queue.shift
      yield cur
      cur.visited = true
      cur.neighbors.select {|n| n.visited == false}.each do |n|
        queue << n
      end
    end
  end

  def connections_for(nodename)
    clear_visited!
    connections = 0
    visit(@nodes.fetch(nodename)) do |node|
      connections += 1 unless node.visited
    end
    connections
  end
end

TEST = <<-EOS
0 <-> 2
1 <-> 1
2 <-> 0, 3, 4
3 <-> 2, 4
4 <-> 2, 3, 6
5 <-> 6
6 <-> 4, 5
EOS
input = if ARGV.any? {|arg| %w(test -t --test).include? arg}
          TEST
        else
          File.read('12.txt').strip
        end
g = Graph.new(input, debug: false)
puts "Part 1: #{g.connections_for(0)}"
puts "Part 2: #{g.groups.count}"
