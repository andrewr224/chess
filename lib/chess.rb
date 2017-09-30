require_relative 'board'
require_relative 'player'
require_relative 'pieces'

class Chess
  attr_reader :board, :players

  def initialize
    @board = Board.new
    @players = [Player.new(:white), Player.new(:black)]
  end

  def play
    place_pieces
    make_a_move until game_over
  end

  def game_over
    false
  end

  def make_a_move
    @board.show_board
    puts "#{@players.first.color.capitalize}'s turn: "

    piece = nil
    target_piece = nil
    from = nil
    to = nil

    until from && to
      squares = @players.first.select_squares
      puts "Selected squares are #{squares}"
      piece = @board.squares[squares[0]]
      target_piece = @board.squares[squares[1]]

      if !piece
        puts "Select a piece to move."
      elsif @players.first.color != piece.color
        puts "Select your piece."
      elsif !@board.validate_path(squares[0], squares[1])
        puts "Illegal move."
      # check if it's an attack
      elsif target_piece
        if target_piece.color == piece.color
          puts "You cannot capture your own piece."
        elsif piece.instance_of?(Pawn) && (squares[0][0] == squares[1][0])
          puts "Illegal move."
        else
          from = squares[0]
          to = squares[1]
        end
      else
        from = squares[0]
        to = squares[1]
      end
    end

    move_pieces(from, to, piece, target_piece)

    @board.show_board
    @players.reverse!
  end


  def move_pieces(from, to, piece, target_piece=nil)
    @board.remove_piece(from)
    @board.add_piece(piece, to)

    if target_piece
      puts "#{@players.first.color.capitalize} captured #{@players.last.color.capitalize}'s #{target_piece.class}"
    end
  end

  def place_pieces
    @black_king = King.new(:black)
    @white_king = King.new(:white)

    @board.add_piece(Rook.new(:black), [1,8])
    @board.add_piece(Knight.new(:black), [2,8])
    @board.add_piece(Bishop.new(:black), [3,8])
    @board.add_piece(Queen.new(:black), [4,8])
    @board.add_piece(@black_king, [5,8])
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
    @board.add_piece(@white_king, [5,1])
    @board.add_piece(Bishop.new(:white), [6,1])
    @board.add_piece(Knight.new(:white), [7,1])
    @board.add_piece(Rook.new(:white), [8,1])
  end
end

#Chess.new.play
