class Player

  def initialize(color)
    @color = color
  end

  def change_to_coordinates(square)
    square = square.dup.split("")
    char = square[0]
    num = square[1].to_i
    char = case char
    when 'a'
      1
    when 'b'
      2
    when 'c'
      3
    when 'd'
      4
    when 'e'
      5
    when 'f'
      6
    when 'g'
      7
    when 'h'
      8
    end

    [char, num]
  end
end
