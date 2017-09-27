class Piece
  attr_accessor :position
  attr_reader :color

  def initialize(color, position)
    @color = color
    @position = position
  end
end

class King < Piece
  def to_s
    "\u2654" if @color == :white
    "\u265A" if @color == :black
  end

  # but it can castle
  def move(square)
    return false if ((@position[0] - square[0]).abs > 1) || ((@position[1] - square[1]).abs > 1)
    @position = square
    true
  end
end

class Pawn < Piece

  def to_s
    "\u2659" if @color == :white
    "\u265F" if @color == :black
  end
  # but it can move two squares on the first move
  # and can attach diagonally
  def move(square)
    return false if (@position[0] != square[0])
    return false if @color == :black && (@position[1] - square[1]) != 1
    return false if @color == :white && (square[1]) - @position[1] != 1
    @position = square
    true
  end
end

class Rook < Piece
  def to_s
    "\u2656" if @color == :white
    "\u265C" if @color == :black
  end

  def move(square)
    return false if (@position[0] != square[0]) && (@position[1] != square[1])
    @position = square
    true
  end
end

class Bishop < Piece
  def to_s
    "\u2657" if @color == :white
    "\u265D" if @color == :black
  end

  def move(square)
    return false if (@position[0] - square[0]).abs != (@position[1] - square[1]).abs
    @position = square
    true
  end
end


class Knight < Piece
  def to_s
    "\u2658" if @color == :white
    "\u265E" if @color == :black
  end

  def move(square)
    return false unless ((@position[0] - square[0]).abs == 1 && (@position[1] - square[1]).abs == 2) || ((@position[0] - square[0]).abs == 2 && (@position[1] - square[1]).abs == 1)
    @position = square
    true
  end
end
