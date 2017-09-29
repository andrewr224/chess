require 'chess'

RSpec.describe 'Pieces' do

  describe 'King' do
    let(:white_king) { King.new(:white) }

    it 'is a King' do
      expect(white_king).to be_instance_of King
    end

    it 'can move one square any direction' do
      expect(white_king.calculate_path([5,2],[5,1])).to be_truthy
      expect(white_king.calculate_path([5,2],[5,3])).to be_truthy
      expect(white_king.calculate_path([5,2],[4,1])).to be_truthy
      expect(white_king.calculate_path([5,2],[6,2])).to be_truthy
    end

    it 'cannot move more than one square at a time' do
      expect(white_king.calculate_path([5,2],[5,4])).to be_falsey
    end
  end

  describe 'Pawn' do
    let(:white_pawn) { Pawn.new(:white) }
    let(:black_pawn) { Pawn.new(:black) }

    it 'is a Pawn' do
      expect(white_pawn).to be_instance_of Pawn
    end

    it 'can move one square ahead' do
      expect(white_pawn.calculate_path([3,2],[3,3],false)).to be_truthy
      expect(black_pawn.calculate_path([3,7],[3,6],false)).to be_truthy
    end

    it 'cannot move more than one square at a time' do
      expect(black_pawn.calculate_path([3,7],[3,4],false)).to be_falsey
    end

    it 'can move two squares at a time from the initial square' do
      expect(white_pawn.calculate_path([3,2],[3,4],false)).to be_truthy
      expect(black_pawn.calculate_path([3,7],[3,5],false)).to be_truthy
    end

    it 'cannot move to the left or rigth' do
      expect(white_pawn.calculate_path([3,2],[4,2],false)).to be_falsey
      expect(black_pawn.calculate_path([3,7],[2,6],false)).to be_falsey
    end

    it 'cannot move back' do
      expect(white_pawn.calculate_path([3,2],[3,1],false)).to be_falsey
      expect(black_pawn.calculate_path([3,7],[3,8],false)).to be_falsey
    end

    it 'can attack diagonally' do
      expect(white_pawn.calculate_path([3,2],[2,3], true)).to be_truthy
      expect(black_pawn.calculate_path([3,7],[2,6], true)).to be_truthy
    end
  end

  describe 'Rook' do
    let(:white_rook) { Rook.new(:white) }
    let(:black_rook) { Rook.new(:black) }

    it 'is a Rook' do
      expect(black_rook).to be_instance_of Rook
    end

    it 'can move any number of squares horizontally' do
      expect(white_rook.calculate_path([5,4],[1,4])).to be_truthy
    end

    it 'can move vertically' do
      expect(black_rook.calculate_path([4,7],[4,1])).to be_truthy
    end

    it 'cannot move diagonally or in any other way' do
      expect(white_rook.calculate_path([5,4],[2,8])).to be_falsey
      expect(black_rook.calculate_path([4,7],[5,6])).to be_falsey
    end
  end

  describe 'Bishop' do
    let(:white_bishop) { Bishop.new(:white) }
    let(:black_bishop) { Bishop.new(:black) }

    it 'has two bishops' do
      expect(white_bishop).to be_instance_of Bishop
    end

    it 'it can move diagonally' do
      expect(white_bishop.calculate_path([5,4],[7,2])).to be_truthy
    end

    it 'cannot move horizontally or vertically' do
      expect(white_bishop.calculate_path([5,4],[5,6])).to be_falsey
      expect(black_bishop.calculate_path([4,6],[2,6])).to be_falsey
    end
  end

  describe 'Knight' do
    let(:white_knight) { Knight.new(:white) }

    it 'has a knight' do
      expect(white_knight).to be_instance_of Knight
    end

    it 'jumps two squares up and one to the side' do
      expect(white_knight.calculate_path([6,1],[7,3])).to be_truthy
    end

    it 'cannot jump to a square outside of it\'s reach' do
      expect(white_knight.calculate_path([6,1],[2,3])).to be_falsey
    end
  end

  describe 'Queen' do
    let(:white_queen) { Queen.new(:white) }

    it 'is a Queen' do
      expect(white_queen).to be_instance_of Queen
    end

    it 'can be printed' do
      expect(white_queen.to_s).to eq("\u2655")
    end

    it 'can move horizontally' do
      expect(white_queen.calculate_path([4,4],[8,4])).to be_truthy
    end

    it 'can move vertically' do
      expect(white_queen.calculate_path([4,4],[4,1])).to be_truthy
    end

    it 'can move diagonally' do
      expect(white_queen.calculate_path([4,4],[1,7])).to be_truthy
    end

    it 'cannot move but in a straight line' do
      expect(white_queen.calculate_path([4,4],[5,6])).to be_falsey
    end
  end
end
