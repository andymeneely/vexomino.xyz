require 'app/constants.rb'

class Block
  attr_accessor :x, :y, :blank, :coords, :birthday, :possible

  def initialize(args, i)
    @args = args
    @x = DRAWER_X
    @y = DRAWER_Y + i * (BLOCK_SIZE + DRAWER_GAP)
    @drawer_x = @x
    @drawer_y = @y
    @blank = false
    @possible = true
    @i = i
    another_one!
  end

  def another_one!
    @coords = PIECE_COORDS.sample
    @blank = false
    @birthday = @args.tick_count
  end

  def dup 
    b = Block.new(@args, @i)
    b.coords = @coords
    b.blank  = @blank
    b.birthday = @birthday
    return b
  end

  def save_for_undo
    @undo_stack << {
      coords: @coords,
      blank: @blank,
      birthday: @birthday
    }
  end

  def undo!
    u = @undo_stack.pop
  end

  # Bounding rectangle of a block
  def rect
    return [@x, @y, BLOCK_SIZE, BLOCK_SIZE]
  end

  def inside_rect?(rect)
    [@x, @y].inside_rect?(rect)
  end

  def let_go!
    @x = @drawer_x
    @y = @drawer_y
  end

  def score
    rows = @coords.map {|(r,_c)| r }
    cols = @coords.map {|(_r,c)| c }
    @coords.size * @coords.size +       # more cells
    5 * (1 + rows.max) * (1 + cols.max) # wider blocks
  end

  def render
    coords.each do | (r,c) |
      dragging = :scorable
      shrink = 3*GAP
      if (@x == @drawer_x && @y == @drawer_y)
        shrink = 0
        dragging = possible ? :filled : :empty
      end
      
      @args.outputs.primitives << {
        primitive_marker: :solid,
        x: @x + c * (SQUARE_SIZE + GAP) + shrink,
        y: @y + r * (SQUARE_SIZE + GAP) + shrink,
        w: SQUARE_SIZE - 2 * shrink,
        h: SQUARE_SIZE - 2 * shrink,
        r: @args.state.pallete[dragging][:r],
        g: @args.state.pallete[dragging][:g],
        b: @args.state.pallete[dragging][:b],
        a: eased_alpha
      }
    end

    # @args.outputs.debug << rect.border
  end

  def eased_alpha
    255.0 * @args.easing.ease(@birthday,
                            @args.tick_count,
                            BLOCK_BIRTHDAY_FADE,
                            :identity)
  end

  def blank?
    @blank
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