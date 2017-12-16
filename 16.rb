class Sixteen
  def self.dance(str, test: true, repeat: 1)
    states = []
    inputs = str.split(",")
    order = if test
              ('a'..'e').to_a
            else
              ('a'..'p').to_a
            end
    repeat.times do |iter|
      if states.include?(order.join)
        return states[repeat % iter]
      else
        states << order.join
      end
      inputs.each do |input|
        case input
        when /s(.+)/
          i = $1.to_i
          order = order[-i..-1] + order[0...-i]
        when /x(\d+)\/(\d+)/
          a = $1.to_i
          b = $2.to_i
          tmp = order[b]
          order[b] = order[a]
          order[a] = tmp
        when /p([a-z])\/([a-z])/
          a = order.index($1)
          b = order.index($2)
          tmp = order[b]
          order[b] = order[a]
          order[a] = tmp
        end
      end
    end
    order.join
  end
end

TEST = "s1,x3/4,pe/b"
input, test = if ARGV.any? {|a| a.include?('t')}
          [TEST, true]
        else
          [File.read('16.txt'), false]
        end
puts "Part 1: #{Sixteen.dance(input, test: test)}"
puts "Part 2: #{Sixteen.dance(input, test: test, repeat: 1_000_000_000)}"
