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
    return "\u2654" if @color == :white
    return "\u265A" if @color == :black
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
    return "\u2659" if @color == :white
    return "\u265F" if @color == :black
  end

  def move(square, attack=false)
    # attach is handled sepparatelly
    if attack && ((@position[0] - square[0]).abs == 1) && ((@position[1] - square[1]).abs == 1)
      @position = square
      true
    end

    # cannot move to a different rank, or move back, or move more than
    # 1 square at a time, exept when it's its innitial square
    return false if (@position[0] != square[0])
    return false if @color == :white && (square[1]) - @position[1] != 1 unless (@position[1] == 2) && (square[1] - @position[1]) == 2
    return false if @color == :black && (@position[1] - square[1]) != 1 unless (@position[1] == 7) && (@position[1] - square[1]) == 2
    @position = square
    true
  end
end

class Rook < Piece
  def to_s
    return "\u2656" if @color == :white
    return "\u265C" if @color == :black
  end

  def move(square)
    return false if (@position[0] != square[0]) && (@position[1] != square[1])
    @position = square
    true
  end
end

class Bishop < Piece
  def to_s
    return "\u2657" if @color == :white
    return "\u265D" if @color == :black
  end

  def move(square)
    return false if (@position[0] - square[0]).abs != (@position[1] - square[1]).abs
    @position = square
    true
  end
end


class Knight < Piece
  def to_s
    return "\u2658" if @color == :white
    return "\u265E" if @color == :black
  end

  def move(square)
    return false unless ((@position[0] - square[0]).abs == 1 && (@position[1] - square[1]).abs == 2) || ((@position[0] - square[0]).abs == 2 && (@position[1] - square[1]).abs == 1)
    @position = square
    true
  end
end

class Queen < Piece
  def to_s
    return "\u2655" if @color == :white
    return "\u265B" if @color == :black
  end

  def move(square)
    #diagonally
    if (@position[0] - square[0]).abs == (@position[1] - square[1]).abs
      @position = square
      true
    #horizontally and vertically
    elsif (@position[0] == square[0]) || (@position[1] == square[1])
      @position = square
      true
    else
      false
    end
  end
end
