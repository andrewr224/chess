require 'squares'

class Board
  def initialize
    @squares = $squares.dup
  end

  def squares
    @squares
  end
end
