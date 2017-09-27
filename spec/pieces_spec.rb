require 'chess'

RSpec.describe 'Pieces' do

  describe 'King' do
    let(:white_king) { King.new(:white, [5,1]) }

    it 'has a King' do
      expect(white_king).to be_truthy
    end

    it 'can move one square any direction' do
      white_king.move([4,1])
      expect(white_king.position).to eq([4,1])
      white_king.move([4,2])
      expect(white_king.position).to eq([4,2])
      white_king.move([5,2])
      expect(white_king.position).to eq([5,2])
      white_king.move([5,1])
      expect(white_king.position).to eq([5,1])
    end

    it 'cannot move more than one square at a time' do
      white_king.move([5,3])
      expect(white_king.position).to_not eq([5,3])
    end
  end

  describe 'Pawn' do
    let(:black_pawn) { Pawn.new(:black, [3,7]) }
    let(:white_pawn) { Pawn.new(:white, [3,2]) }

    it 'has pawns' do
      expect(black_pawn).to be_truthy
      expect(white_pawn).to be_truthy
    end

    it 'can move one square ahead' do
      black_pawn.move([3,6])
      white_pawn.move([3,3])
      expect(black_pawn.position).to eq([3,6])
      expect(white_pawn.position).to eq([3,3])
    end

    it 'cannot move more than one square at a time' do
      black_pawn.move([3,4])
      expect(black_pawn.position).to_not eq([3,4])
    end

    it 'cannot move to the left or rigth' do
      black_pawn.move([2,6])
      white_pawn.move([4,2])
      expect(black_pawn.position).to_not eq([2,6])
      expect(white_pawn.position).to_not eq([4,2])
    end

    it 'cannot move back' do
      black_pawn.move([3,8])
      white_pawn.move([3,1])
      expect(black_pawn.position).to_not eq([3,8])
      expect(black_pawn.position).to eq([3,7])
      expect(white_pawn.position).to_not eq([3,1])
      expect(white_pawn.position).to eq([3,2])
    end
  end

  describe 'Rook' do
    let(:white_rook) { Rook.new(:white, [5,4]) }
    let(:black_rook) { Rook.new(:black, [4,7]) }

    it 'has rooks' do
      expect(black_rook).to be_truthy
      expect(white_rook).to be_truthy
    end

    it 'can move any number of squares horizontally or vertically' do
      white_rook.move([1,4])
      black_rook.move([4,1])
      expect(white_rook.position).to eq([1,4])
      expect(black_rook.position).to eq([4,1])
    end

    it 'cannot move diagonally or in any other way' do
      white_rook.move([2,8])
      black_rook.move([5,6])
      expect(white_rook.position).to_not eq([2,8])
      expect(black_rook.position).to_not eq([5,6])
    end
  end

  describe 'Bishop' do
    let(:white_bishop) { Bishop.new(:white, [5,4]) }
    let(:black_bishop) { Bishop.new(:black, [4,6]) }

    it 'has two bishops' do
      expect(white_bishop).to be_truthy
      expect(black_bishop).to be_truthy
    end

    it 'it can move diagonally' do
      white_bishop.move([7,2])
      expect(white_bishop.position).to eq([7,2])
    end

    it 'cannot move horizontally or vertically' do
      white_bishop.move([5,6])
      black_bishop.move([2,6])
      expect(white_bishop.position).to_not eq([5,6])
      expect(black_bishop.position).to_not eq([2,6])
    end
  end

  describe 'Knight' do
    let(:white_knight) { Knight.new(:white, [6,1]) }

    it 'has a knight' do
      expect(white_knight).to be_truthy
    end

    it 'jumps two squares up and one to the side' do
      white_knight.move([7,3])
      expect(white_knight.position).to eq([7,3])
    end

    it 'cannot jump to a square outside of it\'s reach' do
      white_knight.move([2,3])
      expect(white_knight.position).to_not eq([2,3])
    end
  end
end
