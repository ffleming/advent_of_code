require 'pry-byebug'
target = 347991
def layer_for(num)
  base = 1
  layer = 0
  while base**2 < num
    base += 2
    layer += 1
  end
  layer
end

def side_for_layer(layer)
  layer * 2 + 1
end

def bottom_right_of_layer(layer)
  side_for_layer(layer)**2
end

def bottom_left_of_layer(layer)
  bottom_right_of_layer(layer) - (side_for_layer(layer) - 1)
end

def top_left_of_layer(layer)
  bottom_left_of_layer(layer) - (side_for_layer(layer) - 1)
end

def top_right_of_layer(layer)
  top_left_of_layer(layer) - (side_for_layer(layer) - 1)
end

def min_for_layer(layer)
  bottom_right_of_layer(layer + 1) - 1
end

def is_top?(num)
  layer = layer_for(num)
  (top_right_of_layer(layer)..top_left_of_layer(layer)).include?(num)
end

def is_right?(num)
  layer = layer_for(num)
  (min_for_layer(layer)..top_right_of_layer(layer)).include?(num)
end

def is_bottom?(num)
  layer = layer_for(num)
  (bottom_left_of_layer(layer)..bottom_right_of_layer(layer)).include?(num)
end

def is_left?(num)
  layer = layer_for(num)
  (top_left_of_layer(layer)..bottom_left_of_layer(layer)).include?(num)
end

def is_corner?(num)
  layer = layer_for(num)
  num == top_left_of_layer(layer) ||
    num == top_right_of_layer(layer) ||
    num == bottom_left_of_layer(layer) ||
    num == bottom_right_of_layer(layer)
end


def distance_for(num)
  layer = layer_for(num)
  # if is_corner?(num)
  #   layer * 2
  # end
  x_offset = if is_left?(num) || is_right?(num)
               layer
             elsif is_top?(num)
               mid = (top_right_of_layer(layer) + top_left_of_layer(layer)) / 2
               (num - mid).abs
             elsif is_bottom?(num)
               mid = (bottom_right_of_layer(layer) + bottom_left_of_layer(layer)) / 2
               (num - mid).abs
             end
  y_offset = if is_top?(num) || is_bottom?(num)
               layer
             elsif is_left?(num)
               mid = (bottom_left_of_layer(layer) + top_left_of_layer(layer)) / 2
               (num - mid).abs
             elsif is_right?(num)
               mid = (min_of_layer(layer) + top_right_of_layer(layer) - 1 ) / 2
               (num - mid).abs
             end

  x_offset + y_offset
end

Pry.start
