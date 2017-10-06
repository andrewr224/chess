class Player
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def select_squares
    input = nil
    from = nil
    to = nil

    until from && to
      input = gets.chomp
      squares = input.dup.split unless input.nil?

      if input.empty?
        print "Invalid input. Try again: "
      elsif (squares.length != 2) || (squares[0].length != 2) || (squares[1].length != 2)
        print "Invalid input. Try again: "
      elsif squares[0] == squares[1]
        print "Invalid input. Try again: "
      else
        from = change_to_coordinates(squares[0])
        to = change_to_coordinates(squares[1])
      end
    end

    [from, to]
  end

  def change_to_coordinates(square)
    square = square.split("")
    col = to_number(square[0].downcase)
    row = square[1].to_i

    return false unless col && ((1..8).include? row)
    [col, row]
  end

  def to_number(char)
    col = case char
    when 'a'
      1
    when 'b'
      2
    when 'c'
      3
    when 'd'
      4
    when 'e'
      5
    when 'f'
      6
    when 'g'
      7
    when 'h'
      8
    else
      false
    end
  end
end
