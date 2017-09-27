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

  describe "Pieces" do

    describe "King" do
      let(:white_king) { King.new(:white, 'e1') }

      it "has a King" do
        expect(white_king).to be_truthy
      end

      it "can move one square any direction" do
        white_king.move('d1')
        expect(white_king.position).to eq([4,1])
        white_king.move('d2')
        expect(white_king.position).to eq([4,2])
        white_king.move('e2')
        expect(white_king.position).to eq([5,2])
        white_king.move('e1')
        expect(white_king.position).to eq([5,1])
      end

      it "cannot move more than one square at a time" do
        white_king.move('e3')
        expect(white_king.position).to_not eq([5,3])
      end
    end

    describe "Pawn" do
      let(:black_pawn) { Pawn.new(:black, 'c7') }
      let(:white_pawn) { Pawn.new(:white, 'c2') }

      it "has pawns" do
        expect(black_pawn).to be_truthy
        expect(white_pawn).to be_truthy
      end

      it 'can move one square ahead' do
        black_pawn.move('c6')
        white_pawn.move('c3')
        expect(black_pawn.position).to eq([3,6])
        expect(white_pawn.position).to eq([3,3])
      end

      it 'cannot move more than one square at a time' do
        black_pawn.move('c4')
        expect(black_pawn.position).to_not eq([3,4])
      end

      it 'cannot move to the left or rigth' do
        black_pawn.move('b6')
        white_pawn.move('d2')
        expect(black_pawn.position).to_not eq([2,6])
        expect(white_pawn.position).to_not eq([4,2])
      end

      it 'cannot move back' do
        black_pawn.move('c8')
        white_pawn.move('c1')
        expect(black_pawn.position).to_not eq([3,8])
        expect(black_pawn.position).to eq([3,7])
        expect(white_pawn.position).to_not eq([3,1])
        expect(white_pawn.position).to eq([3,2])
      end
    end
  end
end
