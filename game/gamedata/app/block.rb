require 'app/constants.rb'

class Block
  attr_accessor :x, :y
  attr_reader :coords

  def initialize(args, i)
    @args = args
    @x = DRAWER_X
    @y = DRAWER_Y + i * (BLOCK_SIZE * 1.25)
    @drawer_x = @x
    @drawer_y = @y
    another_one!
  end

  def another_one!
    @coords = PIECE_COORDS.sample
  end

  def rect
    rows = @coords.map {|(r,_c)| r }
    cols = @coords.map {|(_r,c)| c }
    return [
      @x + cols.min * CELL_SIZE - GAP,
      @y + rows.min * CELL_SIZE - GAP,
      (cols.max - cols.min + 1) * CELL_SIZE + GAP,
      (rows.max - rows.min + 1) * CELL_SIZE + GAP
    ]
  end

  def let_go!
    @x = @drawer_x
    @y = @drawer_y
  end

  def score
    @coords.size * @coords.size
  end

  def render
    coords.each do | (r,c) |
      dragging = :scorable
      shrink = 3*GAP
      if (@x == @drawer_x && @y == @drawer_y)
        shrink = 0
        dragging = :filled
      end

      @args.outputs.solids << {
        x: @x + c * (SQUARE_SIZE + GAP) + shrink,
        y: @y + r * (SQUARE_SIZE + GAP) + shrink,
        w: SQUARE_SIZE - 2 * shrink,
        h: SQUARE_SIZE - 2 * shrink,
        r: @args.state.pallete[dragging][0],
        g: @args.state.pallete[dragging][1],
        b: @args.state.pallete[dragging][2]
      }
    end

    # @args.outputs.borders << rect
  end

  def corners
    [
      to_rc(@x,@y),
      to_rc(@x, @y + CELL_SIZE),
      to_rc(@x + CELL_SIZE, @y),
      to_rc(@x + CELL_SIZE, @y + CELL_SIZE)
    ]
  end

  def to_rc(x,y)
    [
      (y - GRID_START_Y).idiv(CELL_SIZE),
      (x - GRID_START_X).idiv(CELL_SIZE),
    ]
  end

  def serialize
    {x: @x, y: @y}
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end