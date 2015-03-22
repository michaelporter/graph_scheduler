#!/usr/bin/env ruby

SWITCHING_COST=5

class Bread
  def initialize(name, prep, rise_1, rise_2, bake)
    @name = name
    @prep = prep
    @rise_1 = rise_1
    @rise_2 = rise_2
    @bake = bake
  end

  attr_reader :name, :prep, :rise_1, :rise_2, :bake
end

class Vertex
  def initialize(name)
    @name = name
    #@visited = false
  end

  attr_reader :name
end

class Graph
  def initialize
    @vertices = []
    @edges = {}
    @breads = []
  end

  def add_bread(bread)
    bread_vertex_names = [
      "#{bread.name}_start",
      "#{bread.name}_prep",
      "#{bread.name}_rise_1",
      "#{bread.name}_rise_2",
      "#{bread.name}_bake"
    ]

    bread_vertex_names.each do |name|
      v = Vertex.new(name)
      @vertices << v
      @edges[name] = {}
    end

    start = find_vertex("#{bread.name}_start")
    prep = find_vertex("#{bread.name}_prep")
    rise_1 = find_vertex("#{bread.name}_rise_1")
    rise_2 = find_vertex("#{bread.name}_rise_2")
    bake = find_vertex("#{bread.name}_bake")

    self.add_edge(start, prep, bread.prep, true)
    self.add_edge(prep, rise_1, bread.rise_1, true)
    self.add_edge(rise_1, rise_2, bread.rise_2, true)
    self.add_edge(rise_2, bake, bread.bake, true)

    # link all prep steps
    @breads.each do |b|
      v = find_vertex("#{b.name}_prep")
      self.add_edge(prep, v, SWITCHING_COST, false)
    end

    @breads << bread
  end

  def add_vertex(name)
    v = Vertex.new(name)
    @vertices << v
    v
  end

  def find_vertex(name)
    vertex = nil
    @vertices.each { |v| vertex = v if v.name == name }
    vertex
  end

  def add_edge(from, to, weight, directional = false)
    @edges[from.name] ||= {}
    base_edge = {:weight => weight, :directional => directional } 

    new_destination = { to.name => base_edge }
    @edges[from.name].merge!(new_destination)

    unless directional
      @edges[to.name] ||= {}
      from_destination = { from.name => base_edge }
      @edges[to.name].merge!(from_destination)
    end

    base_edge
  end

  def show
    @vertices.each do |v|
      edges = @edges[v.name]

      edges.each_pair do |dest_name, info|
        puts "edge from #{v.name} to #{dest_name} with weight #{info[:weight]} and directionality #{info[:directional]}"
      end
    end
  end
end

g = Graph.new
breads = [
  Bread.new("bread_1", 10, 60, 45, 25),
  Bread.new("bread_2", 10, 60, 45, 25),
  Bread.new("bread_3", 10, 60, 45, 25)
]

breads.each { |b| g.add_bread(b) }
g.show

