require 'app/util.rb'

class Cat
  
  def initialize(args)
    @args = args
  end

  def s
    @args.state
  end

  def o
    @args.outputs
  end

  def defaults
    s.cat.x          ||= 4 * CELL_SIZE + GRID_RECT.x
    s.cat.y          ||= 8 * CELL_SIZE + GRID_RECT.y + CELL_SIZE
    s.cat.dx         ||= 0
    s.cat.dy         ||= 4
    s.cat.jumping    ||= false
  end

  def new_level!
    s.cat.x  = GRID_RECT.x + CAT_SIZE
    s.cat.y  = 8 * CELL_SIZE + GRID_RECT.y + CELL_SIZE
    s.cat.dx = 1
    s.cat.dy = rnd8
  end

  def render
    o.primitives << {
      x: s.cat.x,
      y: s.cat.y,
      w: CAT_SIZE,
      h: CAT_SIZE,
      path: 'sprites/feline.png'
    }.to_sprite
    # o.primitives << {
    #   x: s.cat.x,
    #   y: s.cat.y,
    #   w: CAT_SIZE,
    #   h: CAT_SIZE,
    #   path: 'sprites/feline.png'
    # }.to_border
  end

  def calc
    if cat_on_floor?
      s.cat.jumping = false
    else 
      s.cat.y += s.cat.dy
      s.cat.dy -= GRAVITY
    end

    s.cat.x += s.cat.dx

    if on_ledge? || hit_grid_side? || hit_piece?
      s.cat.dx = -1* s.cat.dx
      s.cat.x += 2 * s.cat.dx
    end
  end

  def rescued?
    s.cat.y < 0
  end

  def cat_on_floor?
    return true if s.cat.y < -CELL_SIZE
    r,c = to_rc([s.cat.x + CAT_SIZE / 2, s.cat.y - GAP])
    return is_solid?(r,c)
  end

  def cat_rc
    to_rc(s.cat.x, s.cat.y)
  end

  def on_ledge?
    over_x = s.cat.x + 2* s.cat.dx    
    over_x += CAT_SIZE if s.cat.dx > 0
    r,c = to_rc([over_x, s.cat.y - 3 * GAP])
    # s.debug_str = "#{r}, #{c}"
    return is_empty?(r,c)
  end

  def hit_grid_side?
    x = s.cat.x + 2 * s.cat.dx
    if s.cat.dx > 0 # moving right, check right bound
      s.cat.x + CAT_SIZE > GRID_RECT.x + GRID_RECT.w
    else            # moving left, check lect bound
      s.cat.x < GRID_RECT.x
    end
  end

  def hit_piece?
    x = s.cat.x + 2 * s.cat.dx
    x += CAT_SIZE if s.cat.dx > 0 
    r,c = to_rc([x, s.cat.y + CAT_SIZE / 2])
    return is_solid?(r,c)
  end

  def rect
    [s.cat.x, s.cat.y, CAT_SIZE, CAT_SIZE]
  end
end