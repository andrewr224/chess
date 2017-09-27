require 'board'
require 'player'
require 'pieces'

class Chess

  def initialize
    @board = Board.new
    @players = [Player.new(:white), Player.new(:black)]

  end

  def board
    @board
  end

  def players
    @players
  end

  def pieces
    @pieces
  end
end
