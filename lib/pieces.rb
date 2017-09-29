class Piece
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def horizontal_move(from, to)
    path = []

    if from[0] > to[0]
      next_square = [from[0] - 1, from[1]]
      until next_square == to
        path << next_square
        next_square = [next_square[0] - 1, from[1]]
      end
    else
      next_square = [from[0] + 1, from[1]]
      until next_square == to
        path << next_square
        next_square = [next_square[0] + 1, from[1]]
      end
    end

    path
  end

  def vertical_move(from, to)
    path = []

    if from[1] > to[1]
      next_square = [from[0], from[1] - 1]
      until next_square == to
        path << next_square
        next_square = [from[0], next_square[1] - 1]
      end
    else
      next_square = [from[0], from[1] + 1]
      until next_square == to
        path << next_square
        next_square = [from[0], next_square[1] + 1]
      end
    end

    path
  end

  def diagonal_move(from, to)
    path = []

    if from[0] > to[0]
      if from[1] > to[1]
        next_square = [from[0] - 1, from[1] - 1]
        until next_square == to
          path << next_square
          next_square = [next_square[0] - 1, next_square[1] - 1]
        end
      else
        next_square = [from[0] - 1, from[1] + 1]
        until next_square == to
          path << next_square
          next_square = [next_square[0] - 1, next_square[1] + 1]
        end
      end
    else
      if from[1] > to[1]
        next_square = [from[0] + 1, from[1] - 1]
        until next_square == to
          path << next_square
          next_square = [next_square[0] + 1, next_square[1] - 1]
        end
      else
        next_square = [from[0] + 1, from[1] + 1]
        until next_square == to
          path << next_square
          next_square = [next_square[0] + 1, next_square[1] + 1]
        end
      end
    end

    path
  end
end

class King < Piece
  def to_s
    return "\u2654" if @color == :white
    return "\u265A" if @color == :black
  end

  # but it can castle
  def calculate_path(from, to)
    return false if ((from[0] - to[0]).abs > 1) || ((from[1] - to[1]).abs > 1)
    []
  end
end

class Pawn < Piece
  def to_s
    return "\u2659" if @color == :white
    return "\u265F" if @color == :black
  end

  def calculate_path(from, to, attack)
    return false if @color == :white && (to[1]) - from[1] != 1 unless (from[1] == 2) && (to[1] - from[1]) == 2
    return false if @color == :black && (from[1] - to[1]) != 1 unless (from[1] == 7) && (from[1] - to[1]) == 2
    return [] if attack && ((from[0] - to[0]).abs == 1) && ((from[1] - to[1]).abs == 1)
    return false if (from[0] != to[0])

    vertical_move(from, to)
  end
end

class Rook < Piece
  def to_s
    return "\u2656" if @color == :white
    return "\u265C" if @color == :black
  end

  def validate_move(square)
    true
  end

  def calculate_path(from, to)
    return false if (from[0] != to[0]) && (from[1] != to[1])

    if from[0] == to[0]
      vertical_move(from, to)
    elsif from[1] == to[1]
      horizontal_move(from, to)
    end
  end
end

class Bishop < Piece
  def to_s
    return "\u2657" if @color == :white
    return "\u265D" if @color == :black
  end

  def calculate_path(from, to)
    return false if (from[0] - to[0]).abs != (from[1] - to[1]).abs
    diagonal_move(from, to)
  end
end


class Knight < Piece
  def to_s
    return "\u2658" if @color == :white
    return "\u265E" if @color == :black
  end

  def calculate_path(from, to)
    return false unless ((from[0] - to[0]).abs == 1 && (from[1] - to[1]).abs == 2) || ((from[0] - to[0]).abs == 2 && (from[1] - to[1]).abs == 1)
    []
  end
end

class Queen < Piece
  def to_s
    return "\u2655" if @color == :white
    return "\u265B" if @color == :black
  end

  def calculate_path(from, to)
    if (from[0] - to[0]).abs == (from[1] - to[1]).abs
      diagonal_move(from, to)
    elsif (from[0] == to[0])
      vertical_move(from, to)
    elsif (from[1] == to[1])
      horizontal_move(from, to)
    else
      false
    end
  end
end
