require 'chess'

RSpec.describe "Chess" do
  let(:game) { Chess.new }
  it "is a game" do
    expect(game).to_not be_falsey
  end

  it "has a board" do
    expect(game.board).to be_truthy
  end

  it "has two players" do
    expect(game.players.size).to eq(2)
  end
end
