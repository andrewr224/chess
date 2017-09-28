require 'chess'

RSpec.describe "Chess" do
  let(:game) { Chess.new }
  let(:board) { game.board }
  it "is a game" do
    expect(game).to_not be_falsey
  end

  it "has a board" do
    expect(game.board).to be_truthy
  end

  it "has two players" do
    expect(game.players.size).to eq(2)
  end

  describe "Board" do
    it "has 64 squares" do
      expect(board.squares.size).to eq(64)
    end

    it 'can add a Piece to the Board' do
      board.add_piece(Pawn.new(:white, [2,2]))
      expect(board.squares[[2,2]]).to be_instance_of Pawn
    end

    it 'can remove a Piece from the Board' do
      board.add_piece(Pawn.new(:white, [2,2]))
      board.remove_piece([2,2])
      expect(board.squares[[2,2]]).to be_nil
    end
  end

end
