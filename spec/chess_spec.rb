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
      board.add_piece(Pawn.new(:white, [2,2]))
      expect(board.squares[[2,2]]).to be_instance_of Pawn
    end

    it 'can remove a Piece from the Board' do
      board.add_piece(Pawn.new(:white, [2,2]))
      board.remove_piece([2,2])
      expect(board.squares[[2,2]]).to be_nil
    end
  end

  describe 'Player' do
    $stdin = File.open("./spec/test.txt", "r")
    it 'can select a square' do
      expect(white.select_a_square).to eq([1,1])
      expect(white.select_a_square).to eq([2,4])
    end

    it 'cannot select a square that is not on the board' do
      expect(white.select_a_square).to be_falsey
      expect(white.select_a_square).to be_falsey
    end

    it 'cannot accept invalid input' do
      expect(white.select_a_square).to be_falsey
      expect(white.select_a_square).to be_falsey
    end
  end

end
