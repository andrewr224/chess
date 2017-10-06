require_relative 'squares'

class Board
  attr_reader :squares
  attr_accessor :passing_pawn

  def initialize
    @squares = $layout.dup
    @passing_pawn = nil
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
    !@squares[square].nil?
  end

  def validate_path(from, to)
    piece = @squares[from]
    path = []

    if piece.instance_of? Pawn
      if @passing_pawn
        if to == @passing_pawn[0]
          path = piece.calculate_path(from, to, true)
        end
      else
        path = piece.calculate_path(from, to, validate_presence(to))
      end
    else
      path = piece.calculate_path(from, to)
    end

    return false unless path
    path.each do |square|
      return false unless @squares[square].nil?
    end
    true
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
