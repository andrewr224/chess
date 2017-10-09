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
    take_turn until game_over?
    @board.show_board
    exit
  end

  def game_over?
    if check?(@players.first)
      puts "Check!"
      if mate?(@players.first)
        puts "Mate! #{@players.last.color.capitalize} is victorious!"
        true
      end
    elsif stalemate?(@players.first) || draw?
      puts "It's a draw! (Stalemate)."
      true
    end
  end

  def take_turn
    @board.show_board
    print "\n#{@players.first.color.capitalize}'s turn: "
    make_a_move
    @players.reverse!
  end

  def make_a_move
    moved = false

    until moved
      squares = @players.first.select_squares
      piece = @board.squares[squares[0]]
      target_piece = @board.squares[squares[1]]

      if !piece || @players.first.color != piece.color
        print "Select your piece to move: "
      elsif !@board.validate_path(squares[0], squares[1])
        print "Illegal move. Try again: "
      # check if it's an attack
      elsif target_piece && target_piece.color == piece.color
        print "Square is occupied by your own piece. "
      elsif piece.instance_of?(King)
        moved = kings_move(squares, piece)
      elsif piece.instance_of?(Pawn) && (squares[0][0] == squares[1][0]) && target_piece
        print "Illegal move. Try again: "
      else
        moved = move_pieces(squares[0], squares[1])
      end
    end
  end

  def move_pieces(from, to)
    piece = @board.remove_piece(from)
    target_piece = @board.remove_piece(to)
    @board.add_piece(piece, to)
    pawn = nil

    # capture en passant
    if @board.passing_pawn && piece.instance_of?(Pawn) && (to == @board.passing_pawn[0])
      pawn = @board.passing_pawn[1]
      target_piece = @board.remove_piece(pawn)
    end

    # so the king is not exposed
    if check?(@players.first)
      print "Illegal move: you cannot expose your King."
      @board.add_piece(piece, from)
      if pawn
        @board.add_piece(target_piece, pawn)
      else
        @board.add_piece(target_piece, to)
      end
      return false
    end

    if target_piece
      puts "#{@players.first.color.capitalize} captured #{@players.last.color.capitalize}'s #{target_piece.class}"
    end

    # pawn promotion
    if piece.instance_of?(Pawn) && (to[1] == 8 || to[1] == 1)
      puts "#{@players.first.color.capitalize}'s Pawn has reached the last rank and is to be promoted."
      puts "Please select a piece you want it to be promoted to:"
      puts "(use 'q', 'r', 'b', and 'k' for Queen, Rook, Bishop, and Knight)"
      @board.remove_piece(to)
      @board.add_piece(@players.first.select_piece.new(@players.first.color), to)
    end

    # en passant
    @board.passing_pawn = nil if @board.passing_pawn
    if piece.instance_of?(Pawn) && (from[1] == 2 || from[1] == 7) && (to[1] == 4 || to[1] == 5)
      @board.passing_pawn = [[from[0], (from[1] + to[1]) / 2], to]
    end

    piece.moved = true
    true
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
          attacking_piece = @board.squares[square_1] unless @board.squares[square_1].nil?
          board.remove_piece(square)
          board.add_piece(piece, square_1)
          saved = check?(player)
          board.remove_piece(square_1)
          board.add_piece(piece, square)
          board.add_piece(attacking_piece, square_1) if attacking_piece
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

  def stalemate?(player)
    pieces = @board.squares.select do |square, piece|
      !piece.nil? && piece.color == player.color
    end

    pieces.none? do |location, piece|
      @board.squares.any? do |square, content|
        if square == location
          false
        elsif content && (piece.color == content.color)
          false
        elsif @board.validate_path(location, square)
          @board.remove_piece(location)
          potential_capture = content
          @board.add_piece(piece, square)
          legal = !check?(player)
          @board.remove_piece(square)
          @board.add_piece(piece, location)
          @board.add_piece(potential_capture, square)
          true if legal
        end
      end
    end
  end

  def draw?
    #Just the two Kings on the board.
    #King and Bishop against a King
    #King and Knight against a King
    #King and two Knights against a King

    pieces = []
    @board.squares.each { |square, piece| pieces << piece.class if !piece.nil? && piece.color == @players.first.color}
    if pieces.length == 1
      opponent_pieces = []
      @board.squares.each { |square, piece| opponent_pieces << piece.class if !piece.nil? && piece.color != @players.first.color}

      if opponent_pieces.length <= 3
        if (opponent_pieces - [Knight, King]) == []
          return true
        elsif (opponent_pieces - [Bishop, King]) == []
          return true
        end
      end
    end
    false
  end

  def place_pieces
    @players.each do |player|
      color = player.color
      if color == :white
        rank, pawn_rank = 1, 2
      else
        rank, pawn_rank = 8, 7
      end

      @board.add_piece(Rook.new(color), [1,rank])
      @board.add_piece(Knight.new(color), [2,rank])
      @board.add_piece(Bishop.new(color), [3,rank])
      @board.add_piece(Queen.new(color), [4,rank])
      @board.add_piece(King.new(color), [5,rank])
      @board.add_piece(Bishop.new(color), [6,rank])
      @board.add_piece(Knight.new(color), [7,rank])
      @board.add_piece(Rook.new(color), [8,rank])

      (1..8).each do |col|
        @board.add_piece(Pawn.new(color), [col,pawn_rank])
      end
    end

  end
end

#Chess.new.play
