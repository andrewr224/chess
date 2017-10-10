require_relative 'board'
require_relative 'player'
require_relative 'pieces'
require 'yaml'

class Chess
  attr_reader :board, :players, :white_king

  def initialize
    @board = Board.new
    @players = [Player.new(:white), Player.new(:black)]
  end

  def play
    place_pieces
    puts "Welcome to chess game!"
    puts "Please use explicit syntax (e.g. 'e2 e4') to move pieces."
    puts "You can save, load, or exit your game at any time by entering"
    puts "'save', 'load', or 'exit'."
    puts "You can propose a draw by entering 'draw'."
    puts "Good luck!"
    take_turn until game_over?
    @board.show_board
    exit
  end

  def game_over?
    if check?
      puts "Check!"
      if mate?
        puts "Mate! #{@players.last.color.capitalize} is victorious!"
        true
      end
    elsif stalemate? || draw?
      puts "It's a draw!"
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
      if squares[0].is_a? Symbol
        execute(squares[0])
      end
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

  def execute(command)
    case command
    when :exit
      if @players.last.confirm("exit the game? All unsaved progress will be lost.")
        puts "Exiting the game..."
        exit
      end
    when :load
      load if @players.last.confirm("load the game? Current game will be lost.")
    when :save
      save if @players.last.confirm("save the game? This will replace any previous save.")
    when :draw
      if @players.last.confirm("agree to a draw?")
        puts "The draw was agreed upon."
        puts "Exiting the game now..."
        exit
      end
    end
  end

  def save
    File.open("./save.yaml", "w") do |file|
      file.puts YAML::dump(self)
    end
    puts "Saving complete."
    print "\n#{@players.first.color.capitalize}'s turn: "
  end

  def load
    config = YAML::load(File.read("./save.yaml"))
    @board = config.board
    @players = config.players
    @board.show_board
    puts "Loading complete."
    print "\n#{@players.first.color.capitalize}'s turn: "
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
    if check?
      print "Illegal move: you cannot expose your King. "
      @board.remove_piece(to)
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
      puts "(use 'q', 'r', 'b', and 'k' for Queen, Rook, Bishop, or Knight)"
      @board.remove_piece(to)
      @board.add_piece(@players.first.select_piece.new(@players.first.color), to)
    end

    # en passant
    @board.passing_pawn = nil if @board.passing_pawn
    if piece.instance_of?(Pawn) && !piece.moved && (to[1] == 4 || to[1] == 5)
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
    if check?
      print "Illegal move. Try again: "
      return false
    end

    path = piece.calculate_path(squares[0], squares[1])
    path.pop if path.length > 2
    path.each do |square|
      unless oppressors(square).none?
        print "Illegal move. Try again: "
        return false
      end
    end

    move_pieces(rook_square, [(squares[0][0] + squares[1][0]) / 2, squares[0][1]])
    move_pieces(squares[0], squares[1])
  end

  def check?
    oppressors.any?
  end

  def oppressors(target=find_the_king[1])
    select_pieces(true).select do |square, piece|
      if piece.instance_of?(Pawn)
        piece.calculate_path(square, target, true)
      else
        @board.validate_path(square, target)
      end
    end
  end

  def can_evade?
    kings_square = find_the_king[1]
    king = find_the_king[0]

    moves = king.possible_moves(kings_square).select do |move|
      (@board.squares[move].nil? || @board.squares[move].color != king.color)
    end

    opponent_pieces = select_pieces(true)

    # so king cannot hide behind himself
    @board.remove_piece(kings_square)
    moves.select! do |move|
      opponent_pieces.none? do |square, piece|
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

  def can_block?
    oppressor = oppressors
    attack_line = oppressor.values[0].calculate_path(oppressor.keys[0], find_the_king[1])
    attack_line << oppressor.keys[0]

    pieces = select_pieces.select { |square, piece| !piece.instance_of?(King) }

    attack_line.each do |target_square|
      pieces.each do |square, piece|
        # checking if it will be a check when the piece is moved
        if @board.validate_path(square, target_square)
          enemy_piece = @board.squares[target_square] if @board.squares[target_square]
          board.remove_piece(square)
          board.add_piece(piece, target_square)

          saved = !check?

          board.remove_piece(target_square)
          board.add_piece(piece, square)
          board.add_piece(enemy_piece, target_square) if enemy_piece
          return true if saved
        end
      end
    end
    false
  end

  def mate?
    if oppressors.size > 1
      !can_evade?
    else
      !(can_evade? || can_block?)
    end
  end

  def find_the_king
    king = @board.squares.select do |square, piece|
      !piece.nil? && piece.instance_of?(King) && piece.color == @players.first.color
    end

    [king.values[0], king.keys.flatten]
  end

  def stalemate?
    select_pieces.none? do |location, piece|
      @board.squares.any? do |square, content|
        if square == location
          false
        elsif content && (piece.color == content.color)
          false
        elsif @board.validate_path(location, square)
          @board.remove_piece(location)
          potential_capture = content
          @board.add_piece(piece, square)
          legal = !check?
          @board.remove_piece(square)
          @board.add_piece(piece, location)
          @board.add_piece(potential_capture, square)
          true if legal
        end
      end
    end
  end

  def draw?
    pieces = select_pieces.values.map { |piece| piece.class }
    if pieces.length == 1
      opponent_pieces = select_pieces(true).values.map { |piece| piece.class }
      if (opponent_pieces.length <= 3) && (opponent_pieces - [Knight, King] == [])
        return true
      elsif (opponent_pieces.length <= 2) && (opponent_pieces - [Bishop, King] == [])
        return true
      end
    end
    false
  end

  def select_pieces(opponent=false)
    color = opponent ? @players.last.color : @players.first.color
    @board.squares.select do |square, piece|
      piece && piece.color == color
    end
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
