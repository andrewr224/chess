class Piece
  attr_accessor :position
  attr_reader :color

  def initialize(color, position)
    @color = color
    @position = change_to_coordinates(position)
  end

  def move(square)
    square = change_to_coordinates(square)
  end

  private
  # maybe this will go to the player
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

class King < Piece

  def to_s
    "\u2654"
  end

  def move(square)
    square = change_to_coordinates(square)
    return false if ((@position[0] - square[0]).abs > 1) || ((@position[1] - square[1]).abs > 1)
    @position = square
    true
  end
end

class Pawn < Piece
  def move(square)
    square = change_to_coordinates(square)
    return false if ((@position[0] != square[0]) || ((@position[1] - square[1]).abs > 1))
    @position = square
    true
  end
end

king = King.new(:white, 'e1')
king.move("d4")
