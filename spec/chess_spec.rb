require 'chess'

RSpec.describe "Chess" do
  let(:game) { Chess.new }
  let(:board) { game.board }
  let(:white) { game.players.first }

  it "is a game" do
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
        it 'it confirms that the path is free for a Queen' do
          board.add_piece(Queen.new(:white), [1,1])
          board.add_piece(Queen.new(:black), [4,8])
          expect(board.validate_path([1,1],[8,1])).to be true
          expect(board.validate_path([4,8],[5,8])).to be true
        end
      end

      context 'when the path is not free' do
        it 'it confirms that the path is not free for a Queen' do
          board.add_piece(Queen.new(:white), [1,1])
          board.add_piece(Queen.new(:black), [4,1])
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

  end

  describe '#make_a_move' do
    # too many unfinished methods involved
    it 'can move a Piece on the Board' do
      board.add_piece(Pawn.new(:white), [2,2])
      game.make_a_move
      expect(board.squares[[2,2]]).to be_nil
      expect(board.squares[[2,4]]).to be_instance_of Pawn
    end

    context 'when destination is occupied by a piece of opposite color' do
      it 'allows the capture' do
        board.add_piece(Queen.new(:white), [1,1])
        board.add_piece(Rook.new(:black), [8,1])
        game.make_a_move
        expect(board.squares[[1,1]]).to be_nil
        expect(board.squares[[8,1]]).to be_instance_of Queen
      end
    end
  end


  # next to add: castling
  describe 'Test game' do
    let(:test_game) { Chess.new }
    it 'allwos two players to play a game' do
      expect(test_game.play).to raise_error
    end
  end


end

