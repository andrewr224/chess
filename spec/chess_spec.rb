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

    it "has 32 black squares" do
      expect(board.squares.select{ |k,v| k.size == 3 }.size).to eq(32)
    end
  end

end
