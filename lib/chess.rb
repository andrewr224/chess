require_relative 'board'
require_relative 'player'
require_relative 'pieces'

class Chess
  attr_reader :board, :players, :white_king

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

    @players.reverse!
  end

  def move_pieces(from, to, piece, target_piece=nil)
    @board.remove_piece(from)
    @board.add_piece(piece, to)

    if target_piece
      puts "#{@players.first.color.capitalize} captured #{@players.last.color.capitalize}'s #{target_piece.class}"
    end
  end

  def check?(player)
    oppressors(player, find_the_king(player)[1]).any?
  end

  def oppressors(player, target)
    oppressors = @board.squares.select do |square, piece|
      if !piece.nil? && piece.color != player.color
        if piece.instance_of?(Pawn)
          piece.calculate_path(square, target, true)
        else
          @board.validate_path(square, target)
        end
      end
    end

    oppressors
  end

  def can_evade?(player)
    kings_square = find_the_king(player)[1]
    king = find_the_king(player)[0]

    moves = king.possible_moves(kings_square)
    moves.select! do |move|
      (@board.squares[move].nil? || @board.squares[move].color != king.color)
    end

    enemy_pieces = @board.squares.select do |square, piece|
      !piece.nil? && piece.color != player.color
    end

    # so king cannot hide behind himself
    @board.remove_piece(kings_square)

    moves.select! do |move|
      enemy_pieces.none? do |square, piece|
        if square == move
          false
        elsif piece.instance_of?(Pawn)
          piece.calculate_path(square, move, true)
        else
          @board.validate_path(square, move)
        end
      end
    end

    @board.add_piece(king, kings_square)

    moves.any?
  end

  def can_block?(player, oppressor)
    attack_line = oppressor.values[0].calculate_path(oppressor.keys.flatten, find_the_king(player)[1])

    pieces = @board.squares.select do |square, piece|
      !piece.nil? && !piece.instance_of?(King) && piece.color == player.color
    end

    attack_line.each do |line|
      pieces.each do |square, piece|
        # checking if it will be a check when the piece is moved
        if @board.validate_path(square, line)
          board.remove_piece(square)
          board.add_piece(piece, line)
          saved = check?(player)
          board.remove_piece(line)
          board.add_piece(piece, square)
          return true unless saved
        end
      end
    end

    false
  end

  def can_capture?(player, oppressor)
    pieces = @board.squares.select do |square, piece|
      !piece.nil? && !piece.instance_of?(King) && piece.color == player.color
    end

    oppressor = oppressor.keys.flatten

    pieces.each do |square, piece|
      return true if @board.validate_path(square, oppressor)
    end

  end

  def mate?(player)
    oppressors = oppressors(player, find_the_king(player)[1])
    if oppressors.size > 1
      !can_evade?(player)
    else
      !(can_evade?(player) || can_capture?(player, oppressors) || can_block?(player, oppressors))
    end
  end

  def find_the_king(player)
    king = @board.squares.select do |square, piece|
      !piece.nil? && piece.instance_of?(King) && piece.color == player.color
    end

    [king.values[0], king.keys.flatten]
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
#g = Chess.new
#g.place_pieces
#g.board.check?(g.white_king)
