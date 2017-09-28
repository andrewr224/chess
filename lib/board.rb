require_relative 'squares'

class Board
  def initialize
    @squares = $layout.dup
  end

  def squares
    @squares
  end

  def show_board
    @squares.each do |key,content|
      if key[0] == 1
        print "   --- --- --- --- --- --- --- --- \n"
        print "#{key[1] } "
      end

      if ((key[0] % 2 == 0) && (key[1] % 2 == 0)) || ((key[0] % 2 != 0) && (key[1] % 2 != 0))
        print content.nil? ? "|:::" : "|:#{content}:"
      else
        print content.nil? ? "|   " : "| #{content} "
      end
      if key [0] == 8
        print "|\n"
      end
    end
    puts "   --- --- --- --- --- --- --- --- \n"
    puts "    A   B   C   D   E   F   G   H "
  end
end


Board.new.show_board
