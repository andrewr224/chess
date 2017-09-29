require 'chess'

RSpec.describe 'Pieces' do

  describe 'King' do
    let(:white_king) { King.new(:white, [5,2]) }

    it 'has a King' do
      expect(white_king).to be_instance_of King
    end

    it 'can move one square any direction' do
      expect(white_king.validate_move([5,1])).to be_truthy
      expect(white_king.validate_move([5,3])).to be_truthy
      expect(white_king.validate_move([4,1])).to be_truthy
      expect(white_king.validate_move([6,2])).to be_truthy
    end

    it 'cannot move more than one square at a time' do
      expect(white_king.validate_move([5,4])).to be_falsey
    end
  end

  describe 'Pawn' do
    let(:white_pawn) { Pawn.new(:white, [3,2]) }
    let(:black_pawn) { Pawn.new(:black, [3,7]) }

    it 'has pawns' do
      expect(white_pawn).to be_instance_of Pawn
    end

    it 'can move one square ahead' do
      expect(white_pawn.validate_move([3,3])).to be_truthy
      expect(black_pawn.validate_move([3,6])).to be_truthy
    end

    it 'cannot move more than one square at a time' do
      expect(black_pawn.validate_move([3,4])).to be_falsey
    end

    it 'can move two squares at a time from the initial square' do
      expect(white_pawn.validate_move([3,4])).to be_truthy
      expect(black_pawn.validate_move([3,5])).to be_truthy
    end

    it 'cannot move to the left or rigth' do
      expect(white_pawn.validate_move([4,2])).to be_falsey
      expect(black_pawn.validate_move([2,6])).to be_falsey
    end

    it 'cannot move back' do
      expect(white_pawn.validate_move([3,1])).to be_falsey
      expect(black_pawn.validate_move([3,8])).to be_falsey
    end

    it 'can attack diagonally' do
      expect(white_pawn.validate_move([2,3], true)).to be_truthy
      expect(black_pawn.validate_move([2,6], true)).to be_truthy
    end
  end

  describe 'Rook' do
    let(:white_rook) { Rook.new(:white, [5,4]) }
    let(:black_rook) { Rook.new(:black, [4,7]) }

    it 'has rooks' do
      expect(black_rook).to be_instance_of Rook
    end

    it 'can move any number of squares horizontally' do
      expect(white_rook.validate_move([1,4])).to be_truthy
    end

    it 'can move vertically' do
      expect(black_rook.validate_move([4,1])).to be_truthy
    end

    it 'cannot move diagonally or in any other way' do
      expect(white_rook.validate_move([2,8])).to be_falsey
      expect(black_rook.validate_move([5,6])).to be_falsey
    end
  end

  describe 'Bishop' do
    let(:white_bishop) { Bishop.new(:white, [5,4]) }
    let(:black_bishop) { Bishop.new(:black, [4,6]) }

    it 'has two bishops' do
      expect(white_bishop).to be_instance_of Bishop
    end

    it 'it can move diagonally' do
      expect(white_bishop.validate_move([7,2])).to be_truthy
    end

    it 'cannot move horizontally or vertically' do
      expect(white_bishop.validate_move([5,6])).to be_falsey
      expect(black_bishop.validate_move([2,6])).to be_falsey
    end
  end

  describe 'Knight' do
    let(:white_knight) { Knight.new(:white, [6,1]) }

    it 'has a knight' do
      expect(white_knight).to be_instance_of Knight
    end

    it 'jumps two squares up and one to the side' do
      expect(white_knight.validate_move([7,3])).to be_truthy
    end

    it 'cannot jump to a square outside of it\'s reach' do
      expect(white_knight.validate_move([2,3])).to be_falsey
    end
  end

  describe 'Queen' do
    let(:white_queen) { Queen.new(:white, [4,4]) }

    it 'is a Queen' do
      expect(white_queen).to be_instance_of Queen
    end

    it 'can be printed' do
      expect(white_queen.to_s).to eq("\u2655")
    end

    it 'can move horizontally' do
      expect(white_queen.validate_move([8,4])).to be_truthy
    end

    it 'can move vertically' do
      expect(white_queen.validate_move([4,1])).to be_truthy
    end

    it 'can move diagonally' do
      expect(white_queen.validate_move([1,7])).to be_truthy
    end

    it 'cannot move but in a straight line' do
      expect(white_queen.validate_move([5,6])).to be_falsey
    end
  end
end
