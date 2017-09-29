require_relative 'board'
require_relative 'player'
require_relative 'pieces'

class Chess
  attr_reader :board, :players

  def initialize
    @board = Board.new
    @players = [Player.new(:white), Player.new(:black)]
  end

  def make_a_move
    @board.show_board
    puts "#{@players.first.color.capitalize}'s turn"
    squares = @players.first.select_squares

    # check if there is a piece to move
    unless @board.validate_presence(squares[0])
      puts "Select a piece to move."
      make_a_move
    end

    # check if the path is clear
    unless @board.validate_path(squares[0], squares[1])
      puts "Illegal move."
      make_a_move
    end

    # check if it's an attack
    piece = @board.squares[squares[0]]
    target_piece = nil
    if @board.validate_presence(squares[1])
      target_piece = @board.squares[squares[1]]
      if target_piece.color == piece.color
        puts "You cannot capture your own piece."
        make_a_move
      elsif piece.instance_of?(Pawn) && (squares[0][0] == squares[1][0])
        puts "Illegal move."
        make_a_move
      end
    end


    @board.remove_piece(squares[0])
    @board.add_piece(piece, squares[1])

    if target_piece
      puts "#{@players.first.color.capitalize} captured #{@players.last.color.capitalize}'s #{target_piece.class}"
    end

    @players.reverse!
  end

  def place_pieces
    @board.add_piece(Rook.new(:black), [1,8])
    @board.add_piece(Knight.new(:black), [2,8])
    @board.add_piece(Bishop.new(:black), [3,8])
    @board.add_piece(Queen.new(:black), [4,8])
    @board.add_piece(King.new(:black), [5,8])
    @board.add_piece(Bishop.new(:black), [6,8])
    @board.add_piece(Knight.new(:black), [7,8])
    @board.add_piece(Rook.new(:black), [8,8])

    @board.add_piece(Pawn.new(:black), [1,7])
    @board.add_piece(Pawn.new(:black), [2,7])
    @board.add_piece(Pawn.new(:black), [3,7])
    @board.add_piece(Pawn.new(:black), [4,7])
    @board.add_piece(Pawn.new(:black), [5,7])
    @board.add_piece(Pawn.new(:black), [6,7])
    @board.add_piece(Pawn.new(:black), [7,7])
    @board.add_piece(Pawn.new(:black), [8,7])

    @board.add_piece(Pawn.new(:white), [1,2])
    @board.add_piece(Pawn.new(:white), [2,2])
    @board.add_piece(Pawn.new(:white), [3,2])
    @board.add_piece(Pawn.new(:white), [4,2])
    @board.add_piece(Pawn.new(:white), [5,2])
    @board.add_piece(Pawn.new(:white), [6,2])
    @board.add_piece(Pawn.new(:white), [7,2])
    @board.add_piece(Pawn.new(:white), [8,2])

    @board.add_piece(Rook.new(:white), [1,1])
    @board.add_piece(Knight.new(:white), [2,1])
    @board.add_piece(Bishop.new(:white), [3,1])
    @board.add_piece(Queen.new(:white), [4,1])
    @board.add_piece(King.new(:white), [5,1])
    @board.add_piece(Bishop.new(:white), [6,1])
    @board.add_piece(Knight.new(:white), [7,1])
    @board.add_piece(Rook.new(:white), [8,1])
  end
end
