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
    # [@x, @y, BLOCK_SIZE, BLOCK_SIZE]
    rows = @coords.map {|(r,_c)| r }
    cols = @coords.map {|(_r,c)| c }
    return [
      @x + cols.min * CELL_SIZE, 
      @y + rows.min * CELL_SIZE, 
      (cols.max - cols.min + 1) * CELL_SIZE, 
      (rows.max - rows.min + 1) * CELL_SIZE
    ]
  end

  def let_go!
    @x = @drawer_x
    @y = @drawer_y
  end

  def render
    begin 
    coords.each do | (r,c) |
      @args.outputs.solids << {
        x: @x + c * (SQUARE_SIZE + GAP),
        y: @y + r * (SQUARE_SIZE + GAP),
        w: SQUARE_SIZE,
        h: SQUARE_SIZE,
        r: 20,
        g: 20,
        b: 255
      }
      
    end
    
    @args.outputs.borders << rect
  rescue => e
    puts e.message
    puts "#{@x} #{@y} #{coords}" 
  end
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