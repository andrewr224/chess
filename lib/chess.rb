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
    puts "Welcome to chess game. Please use explicit 'e2 e4' syntax to move pieces."
    make_a_move until game_over?
    puts "Mate! #{@players.last.color.capitalize} is victorious!"
  end

  def game_over?
    mate?(@players.first)
  end

  def make_a_move
    puts "Check!" if check?(@players.first)
    @board.show_board
    print "\n#{@players.first.color.capitalize}'s turn: "

    piece = nil
    target_piece = nil
    from = nil
    to = nil
    moved = false

    until moved
      squares = @players.first.select_squares
      piece = @board.squares[squares[0]]
      target_piece = @board.squares[squares[1]]

      if !piece
        print "Select a piece to move: "
      elsif @players.first.color != piece.color
        print "Select your piece to move: "
      elsif !@board.validate_path(squares[0], squares[1])
        print "Illegal move. Try again: "
      elsif piece.instance_of?(King)
        moved = kings_move(squares, piece)
      # check if it's an attack
      elsif target_piece
        if target_piece.color == piece.color
          print "Square is occupied by your own piece. "
        elsif piece.instance_of?(Pawn) && (squares[0][0] == squares[1][0])
          print "Illegal move. Try again: "
        else
          moved = move_pieces(squares[0], squares[1])
        end
      else
        moved = move_pieces(squares[0], squares[1])
      end
    end

    @players.reverse!
  end

  def kings_move(squares, piece)
    if (squares[1] == [7,1]) && !piece.moved
      if @board.squares[[8,1]].instance_of?(Rook) && !@board.squares[[8,1]].moved
        castle(squares, piece, [8,1])
      else
        print "Illegal move. Try again: "
      end
    elsif (squares[1] == [3,1]) && !piece.moved
      if @board.squares[[1,1]].instance_of?(Rook) && !@board.squares[[1,1]].moved
        castle(squares, piece, [1,1])
      else
        print "Illegal move. Try again: "
      end
    elsif (squares[1] == [7,8]) && !piece.moved
      if @board.squares[[8,8]].instance_of?(Rook) && !@board.squares[[8,8]].moved
        castle(squares, piece, [8,8])
      else
        print "Illegal move. Try again: "
      end
    elsif (squares[1] == [3,8]) && !piece.moved
      if @board.squares[[1,8]].instance_of?(Rook) && !@board.squares[[1,8]].moved
        castle(squares, piece, [1,8])
      else
        print "Illegal move. Try again: "
      end
    else
      move_pieces(squares[0], squares[1])
    end
  end

  def castle(squares, piece, rook_square)
    path = piece.calculate_path(squares[0], squares[1])
    path.pop if path.length > 2
    oppressing_pieces = []

    path.each do |square|
      oppressor = oppressors(@players.first, square)
      oppressing_pieces << oppressor unless oppressor.empty?
    end

    if oppressing_pieces.none? && !check?(@players.first)
      move_pieces(rook_square, [(squares[0][0] + squares[1][0]) / 2, squares[0][1]])
      move_pieces(squares[0], squares[1])
    else
      print "Illegal move. Try again: "
    end
  end

  def move_pieces(from, to)
    piece = @board.remove_piece(from)
    target_piece = @board.remove_piece(to)
    @board.add_piece(piece, to)

    if check?(@players.first)
      print "Illegal move: you cannot expose your King."
      @board.add_piece(piece, from)
      @board.add_piece(target_piece, to)
      return false
    end

    piece.moved = true

    if target_piece
      puts "#{@players.first.color.capitalize} captured #{@players.last.color.capitalize}'s #{target_piece.class}"
    end
    true
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
    attack_line << oppressor.keys[0]

    pieces = @board.squares.select do |square, piece|
      !piece.nil? && !piece.instance_of?(King) && piece.color == player.color
    end

    attack_line.each do |square_1|
      pieces.each do |square, piece|
        # checking if it will be a check when the piece is moved
        if @board.validate_path(square, square_1)
          board.remove_piece(square)
          board.add_piece(piece, square_1)
          saved = check?(player)
          board.remove_piece(square_1)
          board.add_piece(piece, square)
          return true unless saved
        end
      end
    end

    false
  end

  def mate?(player)
    oppressors = oppressors(player, find_the_king(player)[1])
    return false if oppressors.empty?
    if oppressors.size > 1
      !can_evade?(player)
    else
      !(can_evade?(player) || can_block?(player, oppressors))
    end
  end

  def find_the_king(player)
    king = @board.squares.select do |square, piece|
      !piece.nil? && piece.instance_of?(King) && piece.color == player.color
    end

    [king.values[0], king.keys.flatten]
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

#Chess.new.play
