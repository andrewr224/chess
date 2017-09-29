require_relative 'squares'

class Board
  def initialize
    @squares = $layout.dup
  end

  def squares
    @squares
  end

  def add_piece(piece)
    @squares[piece.position] = piece
  end

  def remove_piece(square)
    @squares[square] = nil
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

    path.each do |square|
      return false unless @squares[square].nil?
    end
    true
  end

  def show_board
    puts
    @squares.each do |key,content|
      if key[0] == 1
        print "   --- --- --- --- --- --- --- --- \n"
        print "#{key[1] } "
      end

      if ((key[0] % 2 == 0) && (key[1] % 2 == 0)) || ((key[0] % 2 != 0) && (key[1] % 2 != 0))
        print content.nil? ? "|:::" : "|:#{content}:"
      else
        print content.nil? ? "|   " : "| #{content} "
      end
      if key [0] == 8
        print "|\n"
      end
    end
    puts "   --- --- --- --- --- --- --- --- \n"
    puts "    A   B   C   D   E   F   G   H "
  end
end
