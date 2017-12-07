require 'pry-byebug'
require 'set'
class Node
  attr_accessor :parent, :weight, :children, :name
  def initialize(parent: , weight: , children: , name: )
    @parent = parent
    @weight = weight
    @children = children
    @name = name
  end

  def total_weight
    total = weight
    children.each do |child|
      total += child.total_weight
    end
    total
  end

  def broken?
    children.map(&:total_weight).uniq.size != 1
  end
end

class Graph
  attr_reader :nodes
  def self.from(filename)
    n = new
    File.foreach(filename) do |line|
      n.add_node(line)
    end
    n
  end

  def initialize
    @nodes = {}
  end

  def broken_info
    prev = nil
    cur = root
    while cur
      broken_node = cur.children.select {|n| n.broken?}.first # assumes only one is broken
      break if broken_node.nil?
      prev = cur
      cur = broken_node
    end
    broken_node = cur
    weights = broken_node.children.map(&:weight)
    total_weights = broken_node.children.map(&:total_weight)
    puts "Found broken node #{broken_node.name} of weight #{broken_node.weight}"
    puts "Children are of weight #{weights}"
    puts "Children are of total_weight #{total_weights}"
    puts "No children are broken"
    # n^2, fix if it matters
    correct = total_weights.detect {|n| total_weights.count(n) > 1 }
    # let's just go ahead and laught that set has an accessor that semantically assumes order
    incorrect = (Set.new(total_weights) - Set.new([correct])).first
    puts "The correct weight is #{correct}, the incorrect weight is #{incorrect}"
    incorrect_offset = correct - incorrect
    incorrect_i = total_weights.index(incorrect)
    puts "Incorrect node is of by #{incorrect_offset}, should be #{broken_node.children[incorrect_i].weight + incorrect_offset}"
  end

  def root
    return @root if defined?(@root)
    _root = nodes.first[1]
    while _root.parent != nil
      _root = _root.parent
    end
    @root = _root
  end

  def add_node(line)
    name_weight, children = line.split("->", 2).map(&:strip)
    m = name_weight.match(/(?<name>[a-z]+) \((?<weight>\d+)\)/)
    name = m['name'].strip
    weight = m['weight'].strip.to_i

    child_nodes = []

    node = if @nodes[name]
             @nodes[name]
           else
             Node.new(children: child_nodes, weight: weight, name: name, parent: nil)
           end

    if !children.nil?
      children = children.split(",").map(&:strip)
      child_nodes = children.map do |child_name|
        child = case @nodes[child_name]
                when NilClass
                  n = Node.new(name: child_name, weight: -1, parent: node, children: [])
                  @nodes[child_name] = n
                  n
                when Node
                  @nodes[child_name]
                end
        child.parent = node
        child
      end
    end

    node.children = child_nodes
    node.weight = weight
    node.name = name
    @nodes[name] = node if @nodes[name].nil?
  end
end

g = Graph.from("7.txt")
puts "Root is #{g.root.name}"
g.broken_info
