require 'board'
require 'player'
require 'pieces'

class Chess
  attr_reader :board, :players

  def initialize
    @board = Board.new
    @players = [Player.new(:white), Player.new(:black)]
  end

  def make_a_move
    #@board.show_board
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
end
