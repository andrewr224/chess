class Player
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def select_squares
    from = nil
    to = nil

    until from && to
      input = gets.chomp.downcase

      case input
      when "exit"
        from = :exit
        to = ""
      when "save"
        from = :save
        to = ""
      when "load"
        from = :load
        to = ""
      when "draw"
        from = :draw
        to = ""
      else
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
          print "Invalid input. Try again: " unless from && to
        end
      end
    end

    [from, to]
  end

  def change_to_coordinates(square)
    square = square.split("")
    col = to_number(square[0])
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

  def select_piece
    choice = nil
    until choice
      choice = case gets.chomp.downcase[0]
      when 'q'
        Queen
      when 'r'
        Rook
      when 'b'
        Bishop
      when 'k'
        Knight
      else
        nil
      end
    end
    choice
  end

  def confirm(thing)
    print "Are you sure you want to #{thing}\n[Y/N] "
    choice = nil
    until choice
      choice = case gets.chomp.downcase[0]
      when 'y'
        return true
      when 'n'
        return false
      else
        print "Please enter 'Y' or 'N': "
      end
    end
  end
end
