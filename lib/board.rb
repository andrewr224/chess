require_relative 'squares'

class Board
  attr_reader :squares

  def initialize
    @squares = $layout.dup
  end

  def add_piece(piece, position)
    @squares[position] = piece
  end

  def remove_piece(square)
    piece = @squares[square]
    @squares[square] = nil
    piece
  end

  def validate_presence(square)
    return false if @squares[square].nil?
    true
  end

  def validate_path(from, to)
    piece = @squares[from]
    path = []

    if piece.instance_of? Pawn
      path = piece.calculate_path(from, to, validate_presence(to))
    else
      path = piece.calculate_path(from, to)
    end

    return false unless path
    path.each do |square|
      return false unless @squares[square].nil?
    end
    true
  end

  def castle(to)
    case to
    when [7,1]
      king = remove_piece([5,1])
      rook = remove_piece([8,1])
      add_piece(king, [7,1])
      add_piece(rook, [6,1])
    when [7,8]
      king = remove_piece([5,8])
      rook = remove_piece([8,8])
      add_piece(king, [7,8])
      add_piece(rook, [6,8])
    when [3,1]
      king = remove_piece([5,1])
      rook = remove_piece([1,1])
      add_piece(king, [3,1])
      add_piece(rook, [4,1])
    when [3,8]
      king = remove_piece([5,8])
      rook = remove_piece([1,8])
      add_piece(king, [3,8])
      add_piece(rook, [4,8])
    end
  end

  def check?(player)
    king = @squares.select do |square, piece|
      !piece.nil? && piece.instance_of?(King) && piece.color == player.color
    end

    enemy_pieces = @squares.select do |square, piece|
      !piece.nil? && piece.color != player.color
    end


    enemy_pieces.each do |square, piece|
      return true if validate_path(square, king.keys.flatten)
    end
    false
  end

  def show_board
    puts
    squares.each do |square,piece|
      if square[0] == 1
        print "   --- --- --- --- --- --- --- --- \n"
        print "#{square[1] } "
      end

      if ((square[0] % 2 == 0) && (square[1] % 2 == 0)) || ((square[0] % 2 != 0) && (square[1] % 2 != 0))
        print piece.nil? ? "|:::" : "|:#{piece}:"
      else
        print piece.nil? ? "|   " : "| #{piece} "
      end
      if square [0] == 8
        print "|\n"
      end
    end
    puts "   --- --- --- --- --- --- --- --- \n"
    puts "    A   B   C   D   E   F   G   H "
  end
end
