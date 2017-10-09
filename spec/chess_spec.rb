require 'chess'

RSpec.describe "Chess" do
  let(:game) { Chess.new }
  let(:board) { game.board }
  let(:white) { game.players.first }

  it "is a Chess game" do
    expect(game).to be_instance_of Chess
  end

  it "has a board" do
    expect(game.board).to be_instance_of Board
  end

  it "has two players" do
    expect(game.players.size).to eq(2)
  end

  describe "Board" do
    it "has 64 squares" do
      expect(board.squares.size).to eq(64)
    end

    it 'can add a Piece to the Board' do
      board.add_piece(Pawn.new(:white), [2,2])
      expect(board.squares[[2,2]]).to be_instance_of Pawn
    end

    it 'can remove a Piece from the Board' do
      board.add_piece(Pawn.new(:white), [2,2])
      expect(board.squares[[2,2]]).to be_instance_of Pawn
      board.remove_piece([2,2])
      expect(board.squares[[2,2]]).to be_nil
    end

    it 'checks if the square is occupied' do
      board.add_piece(King.new(:black), [2,2])
      expect(board.validate_presence([1,2])).to be_falsey
      expect(board.validate_presence([2,2])).to be_truthy
    end

    describe '#validate_path' do
      context 'when the path is free' do
        it 'it confirms that the path is free' do
          board.add_piece(Queen.new(:white), [1,1])
          board.add_piece(Queen.new(:black), [4,8])
          expect(board.validate_path([1,1],[8,1])).to be true
          expect(board.validate_path([4,8],[5,8])).to be true
        end
      end

      context 'when the path is not free' do
        it 'it confirms that the path is not free' do
          board.add_piece(Rook.new(:white), [1,1])
          board.add_piece(Knight.new(:black), [4,1])
          expect(board.validate_path([1,1],[8,1])).to be false
        end
      end
    end
  end

  describe 'Player' do
    $stdin = File.open("./spec/test.txt", "r")
    it 'can select squares to move a piece' do
      expect(white.select_squares).to eq([[1,1], [2,3]])
      expect(white.select_squares).to eq([[2,4], [3,3]])
    end

    it 'cannot select invalid squares' do
      # ""
      # asd
      # v1 w5
      expect(white.select_squares).to eq([[5,2], [5,4]])
    end

  end

  describe '#make_a_move' do
    # too many unfinished methods involved
    it 'can move a Piece on the Board' do
      board.add_piece(King.new(:white), [5,1])
      board.add_piece(Pawn.new(:white), [2,2])
      game.make_a_move
      expect(board.squares[[2,2]]).to be_nil
      expect(board.squares[[2,4]]).to be_instance_of Pawn
    end

    context 'when destination is occupied by a piece of opposite color' do
      it 'allows the capture' do
        board.add_piece(King.new(:white), [5,2])
        board.add_piece(Queen.new(:white), [1,1])
        board.add_piece(Rook.new(:black), [8,1])
        game.make_a_move
        expect(board.squares[[1,1]]).to be_nil
        expect(board.squares[[8,1]]).to be_instance_of Queen
      end
    end

    context 'when destination is occupied by a piece of same color' do
      it 'does not allow capture, but prompts user from new input' do
        board.add_piece(King.new(:white), [5,1])
        board.add_piece(Knight.new(:white), [3,1])
        board.add_piece(Pawn.new(:white), [4,3])
        # c1 d3 - fails
        # c1 e2 - works
        game.make_a_move
        expect(board.squares[[3,1]]).to be_nil
        expect(board.squares[[4,3]]).to be_instance_of Pawn
        expect(board.squares[[5,2]]).to be_instance_of Knight
      end
    end

    context 'when player selects a square with no piece' do
      it 'gets another input from player' do
        board.add_piece(King.new(:white), [5,1])
        board.add_piece(Pawn.new(:white), [5,2])
        # d2 d4
        # e2 e4
        game.make_a_move
        expect(board.squares[[5,2]]).to be_nil
        expect(board.squares[[5,4]]).to be_instance_of Pawn
      end
    end

    context 'when player selects a piece that is not his/hers' do
      it 'does not allow the move' do
        board.add_piece(King.new(:white), [5,1])
        board.add_piece(Knight.new(:black), [5,5])
        board.add_piece(Pawn.new(:white), [4,3])

        # e5 d3 - fails
        # d3 d4 - works
        game.make_a_move
        expect(board.squares[[5,5]]).to be_instance_of Knight
        expect(board.squares[[4,3]]).to be_nil
        expect(board.squares[[4,4]]).to be_instance_of Pawn
      end
    end
  end

  describe '#check?' do
    it 'sais that the king is not in check when he isn\'t' do
      board.add_piece(King.new(:white), [5,8])
      board.add_piece(Rook.new(:black), [2,7])
      board.add_piece(Rook.new(:black), [6,1])
      board.add_piece(Bishop.new(:black), [5,6])
      expect(game.check?).to be false
    end

    it 'sais that the king is in check when he is' do
      board.add_piece(King.new(:white), [5,1])
      board.add_piece(Rook.new(:black), [5,7])
      board.add_piece(Rook.new(:black), [6,2])
      board.add_piece(Bishop.new(:black), [3,3])
      expect(game.check?).to be true
    end

    it 'does not allow a move if it exposes a check' do
      board.add_piece(King.new(:white), [5,1])
      board.add_piece(Rook.new(:white), [6,2])
      board.add_piece(Rook.new(:black), [4,7])
      board.add_piece(Bishop.new(:black), [7,3])
      # e1 d1 -false
      # f2 f8 -false
      # e1 e2 -true
      game.make_a_move
      expect(board.squares[[6,2]]).to be_instance_of Rook
      expect(board.squares[[4,1]]).to be_nil
      expect(board.squares[[5,2]]).to be_instance_of King
    end
  end

  describe '#mate?' do
    it 'sais that the king is not in mate when he can evade it' do
      board.add_piece(King.new(:white), [5,1])
      board.add_piece(Queen.new(:white), [6,1])
      board.add_piece(Rook.new(:black), [1,1])
      board.add_piece(Pawn.new(:black), [6,2])
      board.add_piece(Bishop.new(:black), [3,3])
      expect(game.mate?).to be false
    end

    it 'sais that the king is not in mate when he can capture the oppressor' do
      board.add_piece(King.new(:white), [8,1])
      board.add_piece(Queen.new(:black), [7,2])
      board.add_piece(King.new(:black), [1,1])
      expect(game.mate?).to be false
    end

    it 'sais that the king is not in mate when the oppressor can be captured' do
      board.add_piece(King.new(:white), [1,1])
      board.add_piece(Queen.new(:white), [8,2])
      board.add_piece(Pawn.new(:white), [7,2])
      board.add_piece(Rook.new(:black), [7,1])
      board.add_piece(Rook.new(:black), [6,2])
      expect(game.mate?).to be false
    end

    it 'sais that the king is not in mate when it can be blocked' do
      board.add_piece(King.new(:white), [1,1])
      board.add_piece(Queen.new(:white), [4,3])
      board.add_piece(Rook.new(:black), [8,1])
      board.add_piece(Rook.new(:black), [8,2])
      expect(game.mate?).to be false
    end

    it 'sais that the king is in mate when he is' do
      board.add_piece(King.new(:white), [5,1])
      board.add_piece(Queen.new(:white), [6,1])
      board.add_piece(Rook.new(:black), [1,1])
      board.add_piece(Rook.new(:black), [8,2])
      board.add_piece(Bishop.new(:black), [3,3])
      expect(game.mate?).to be true
    end
  end

  describe 'castling' do
    context 'when the path is clear' do
      it 'can castle kingside for white' do
        board.add_piece(King.new(:white), [5,1])
        board.add_piece(Rook.new(:white), [8,1])
        game.make_a_move
        expect(board.squares[[5,1]]).to be_nil
        expect(board.squares[[8,1]]).to be_nil
        expect(board.squares[[7,1]]).to be_instance_of King
        expect(board.squares[[6,1]]).to be_instance_of Rook
      end

      it 'can castle queenside for white' do
        board.add_piece(King.new(:white), [5,1])
        board.add_piece(Rook.new(:white), [1,1])
        board.add_piece(Queen.new(:black), [2,8])
        game.make_a_move
        expect(board.squares[[3,1]]).to be_instance_of King
        expect(board.squares[[4,1]]).to be_instance_of Rook
      end

      it 'can castle kingside for black' do
        board.add_piece(King.new(:black), [5,8])
        board.add_piece(Rook.new(:black), [8,8])
        game.players.reverse!
        game.make_a_move
        expect(board.squares[[7,8]]).to be_instance_of King
        expect(board.squares[[6,8]]).to be_instance_of Rook
      end

      it 'can castle queenside for black' do
        board.add_piece(King.new(:black), [5,8])
        board.add_piece(Rook.new(:black), [1,8])
        game.players.reverse!
        game.make_a_move
        expect(board.squares[[3,8]]).to be_instance_of King
        expect(board.squares[[4,8]]).to be_instance_of Rook
      end
    end

    context 'when the path is obstructed' do
      it 'cannot castle kingside for white' do
        board.add_piece(King.new(:white), [5,1])
        board.add_piece(Bishop.new(:white), [6,1])
        board.add_piece(Rook.new(:white), [8,1])
        game.make_a_move
        expect(board.squares[[4,3]]).to be_instance_of Bishop
        expect(board.squares[[5,1]]).to be_instance_of King
        expect(board.squares[[8,1]]).to be_instance_of Rook
      end

      it 'cannot castle queenside for black' do
        board.add_piece(King.new(:black), [5,8])
        board.add_piece(Queen.new(:black), [4,8])
        board.add_piece(Rook.new(:black), [1,8])
        game.players.reverse!
        game.make_a_move
        expect(board.squares[[5,8]]).to be_instance_of King
        expect(board.squares[[1,8]]).to be_instance_of Rook
      end
    end

    context 'when the path is under check' do
      it 'cannot castle kingside for white' do
        board.add_piece(King.new(:white), [5,1])
        board.add_piece(Bishop.new(:black), [5,2])
        board.add_piece(Rook.new(:white), [8,1])
        game.make_a_move
        expect(board.squares[[5,1]]).to be_instance_of King
        expect(board.squares[[8,2]]).to be_instance_of Rook
      end

      it 'cannot castle queenside for black' do
        board.add_piece(King.new(:black), [5,8])
        board.add_piece(Rook.new(:black), [1,8])
        board.add_piece(Queen.new(:white), [4,3])
        game.players.reverse!
        game.make_a_move
        expect(board.squares[[5,8]]).to be_instance_of King
        expect(board.squares[[1,3]]).to be_instance_of Rook
      end
    end

    context 'when the King is in check' do
      it 'cannot castle kingside for white' do
        board.add_piece(King.new(:white), [5,1])
        board.add_piece(Rook.new(:white), [8,1])
        board.add_piece(Knight.new(:black), [4,3])
        game.make_a_move
        expect(board.squares[[7,1]]).to be_nil
        expect(board.squares[[8,1]]).to be_instance_of Rook
      end

      it 'cannot castle queenside for black' do
        board.add_piece(King.new(:black), [5,8])
        board.add_piece(Rook.new(:black), [1,8])
        board.add_piece(Pawn.new(:white), [6,7])
        game.players.reverse!
        game.make_a_move
        expect(board.squares[[6,8]]).to be_instance_of King
        expect(board.squares[[1,8]]).to be_instance_of Rook
      end
    end

    context 'when there is no Rook' do
      it 'cannot castle queenside for white' do
        board.add_piece(King.new(:white), [5,1])
        board.add_piece(Knight.new(:white), [1,1])
        game.make_a_move
        expect(board.squares[[5,1]]).to be_instance_of King
      end

      it 'cannot castle kingside for black' do
        board.add_piece(King.new(:black), [5,8])
        board.add_piece(Bishop.new(:black), [8,7])
        game.players.reverse!
        game.make_a_move
        expect(board.squares[[5,8]]).to be_instance_of King
        expect(board.squares[[7,6]]).to be_instance_of Bishop
      end
    end

    context 'when the King or a Rook have moved' do
      it 'cannot castle kingside if King has moved' do
        board.add_piece(King.new(:white), [5,1])
        board.add_piece(Rook.new(:white), [8,1])
        game.make_a_move
        game.make_a_move
        game.make_a_move
        expect(board.squares[[5,1]]).to be_instance_of King
        expect(board.squares[[8,2]]).to be_instance_of Rook
      end

      it 'cannot castle kingside if Rook has moved' do
        board.add_piece(King.new(:white), [5,1])
        board.add_piece(Rook.new(:white), [8,1])
        game.make_a_move
        game.make_a_move
        game.make_a_move
        expect(board.squares[[5,2]]).to be_instance_of King
        expect(board.squares[[8,1]]).to be_instance_of Rook
      end
    end
  end

  describe 'Pawn promotion' do
    context 'when Pawn reaches the last rank' do
      it 'is promoted to a white Queen' do
        board.add_piece(Pawn.new(:white), [4,7])
        game.move_pieces([4,7],[4,8])
        expect(board.squares[[4,8]]).to be_instance_of Queen
      end

      it 'is promoted to a black Rook' do
        board.add_piece(King.new(:white), [1,1])
        board.add_piece(King.new(:black), [1,8])
        board.add_piece(Pawn.new(:black), [4,2])
        board.add_piece(Knight.new(:white), [5,1])
        game.move_pieces([4,2],[5,1])
        expect(board.squares[[5,1]]).to be_instance_of Rook
      end
    end
  end

  describe 'en passant' do
    it 'can capture en passant' do
      board.add_piece(King.new(:white), [1,1])
      board.add_piece(King.new(:black), [1,8])
      board.add_piece(Pawn.new(:white), [4,2])
      board.add_piece(Pawn.new(:black), [5,4])
      game.make_a_move
      game.players.reverse!
      game.make_a_move
      expect(board.squares[[4,3]]).to be_instance_of Pawn
      expect(board.squares[[4,4]]).to be nil
    end
  end

  describe 'Draw by' do
    context 'stalemate' do
      it 'declares a draw when there are no legal moves' do
        board.add_piece(King.new(:white), [7,1])
        board.add_piece(Pawn.new(:white), [7,7])
        board.add_piece(King.new(:black), [7,8])
        board.add_piece(Queen.new(:black), [5,3])
        game.make_a_move
        game.players.reverse!
        game.make_a_move
        game.players.reverse!
        expect(game.stalemate?).to be true
        game.players.reverse!
        expect(game.stalemate?).to be false
      end
    end

    context 'insufficient material' do
      it 'declares a draw' do
        board.add_piece(King.new(:white), [5,1])
        board.add_piece(King.new(:black), [5,8])
        expect(game.draw?).to be true
      end

      it 'declares a draw' do
        board.add_piece(King.new(:white), [5,1])
        board.add_piece(Knight.new(:black), [3,8])
        board.add_piece(Knight.new(:black), [3,7])
        board.add_piece(King.new(:black), [5,8])
        expect(game.draw?).to be true
      end

      it 'does not declare a draw' do
        board.add_piece(King.new(:white), [5,1])
        board.add_piece(Queen.new(:black), [3,4])
        board.add_piece(King.new(:black), [5,8])
        expect(game.draw?).to be false
      end
    end
  end
end

