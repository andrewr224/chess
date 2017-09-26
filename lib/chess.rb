require 'board'
require 'player'

class Chess

  def initialize
    @board = Board.new
    @players = [Player.new, Player.new]
  end

  def board
    @board
  end

  def players
    @players
  end
end
