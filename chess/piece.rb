require "singleton"
require "colorize"

class Piece
  STRAIGHTS = [[1, 0], [-1, 0], [0, 1], [0, -1]]
  DIAGONALS = [[1, 1], [-1, 1], [1, -1], [-1, -1]]
  KNIGHTS = [[-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1]]

  MOVES = {
    rook: STRAIGHTS,
    bishop: DIAGONALS,
    queen: STRAIGHTS + DIAGONALS,
    king: STRAIGHTS + DIAGONALS,
    knight: KNIGHTS,
    pawn: [[1, 0], [1, 1], [1, -1]]
  }

  WHITE_PRINTABLE = {
    rook: "\u2656",
    bishop: "\u2657",
    queen: "\u2655",
    king: "\u2654",
    knight: "\u2658",
    pawn: "\u265f"
  }

  BLACK_PRINTABLE = {
    rook: "\u265c",
    bishop: "\u265d",
    queen: "\u265b",
    king: "\u265a",
    knight: "\u265e",
    pawn: "\u2659"
  }

  attr_reader :board, :color, :name
  attr_accessor :pos

  def initialize(pos, board, color, name)
    @pos = pos
    @board = board
    @color = color
    @name = name
  end

  def to_s
    if @color == :white
      WHITE_PRINTABLE[@name]
    else
      BLACK_PRINTABLE[@name]
    end
  end

  def add_array(arr1, arr2)
    [arr1.first + arr2.first, arr1.last + arr2.last]
  end

  def valid_move?(pos)
    @board[*pos].color != @color && @board.in_bounds?(pos)
  end
end

class SlidingPiece < Piece

  def multiplier(arr, number)
    arr.map { |el| el * number }
  end

  def moves
    result = []
    MOVES[name].each do |move|
      (1..7).each do |idx|
        new_pos = add_array(pos, multiplier(move,idx))
        valid_move?(new_pos) ? result << new_pos : break
      end
    end
    result
  end

end

class SteppingPiece < Piece

  def moves
    result = []
    MOVES[name].each do |move|
      new_pos = add_array(pos, move)
      result << move if valid_move?(new_pos)
    end
    result
  end

end

class Pawn < Piece
  attr_reader :multiplier

  def initialize(pos, board, color, name)
    super(pos, board, color, name)
    @moved = false
    @multiplier = (@color == :white ? -1 : 1)
  end

  def moves
    result = []
    unless @moved
      forward_moves = [[1, 0], [2, 0]].map { |move| move.map { |el| el * multiplier } }
      possible_moves = forward_moves.select do |move|
        valid_move?(add_array(move, pos))
      end
      result.concat(possible_moves)
    else
      forward_move = [1, 0].map { |el| el * multiplier }
      new_pos = add_array(forward_move, pos)

      result.concat(forward_move) if valid_move?(new_pos)
    end
    diagonal_moves = [[1, -1], [1, 1]].map { |move| move.map { |el| el * multiplier } }
    possible_moves = diagonal_moves.select do |move|
      valid_move?(add_array(move, pos))
    end
    result.concat(possible_moves)
  end
end

class NullPiece
  include Singleton

  def moves
  end

  def to_s
    " "
  end

  def add_array(arr1, arr2)
  end

  def valid_move?(pos)
  end

  attr_reader :board, :color, :name
  attr_accessor :pos

end
