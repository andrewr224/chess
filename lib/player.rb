class Player

  def initialize(color)
    @color = color
  end

  def select_a_square
    input = gets.chomp
    return false if input.length != 2

    square = input.dup.split("")

    col = change_to_number(square[0].downcase)
    num = square[1].to_i

    return false unless col
    return false unless (1..8).include? num

    [col, num]
  end

  def change_to_number(char)
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
