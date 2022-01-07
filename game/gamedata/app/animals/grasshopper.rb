class Grasshopper
  
  def initialize(args)
    @args = args
    @next_x = rnd_jump
    @next_y = rnd_jump
  end

  def s
    @args.state
  end

  def o
    @args.outputs
  end

  def defaults
    s.grasshopper.x          ||= GRID_RECT.x + 200
    s.grasshopper.y          ||= GRID_RECT.y + GRID_RECT.h - CELL_SIZE / 2
    s.grasshopper.next_dx    ||= rnd_dx
    s.grasshopper.next_dy    ||= rnd_dy
    s.grasshopper.dx         ||= 1
    s.grasshopper.dy         ||= 4
    s.grasshopper.jumping    ||= false
    s.grasshopper.eaten      ||= false
  end

  def new_level!
    s.grasshopper.x  = GRID_RECT.x + GRID_RECT.w - CELL_SIZE
    s.grasshopper.y  = GRID_RECT.y + GRID_RECT.h - CELL_SIZE
    s.grasshopper.next_dx    = rnd_dx
    s.grasshopper.next_dy    = rnd_dy
    s.grasshopper.dx = rnd_dx
    s.grasshopper.dy = rnd_dy
    s.grasshopper.jumping   = false
    s.grasshopper.eaten     = false
    
  end

  def render
    return if rescued?
    o.primitives << {
      x: s.grasshopper.x,
      y: s.grasshopper.y,
      w: CAT_SIZE,
      h: CAT_SIZE,
      path: 'sprites/cricket.png'
    }.to_sprite
    # o.primitives << {
    #   x: s.grasshopper.x,
    #   y: s.grasshopper.y,
    #   w: CAT_SIZE,
    #   h: CAT_SIZE,
    # }.to_border
    render_next_jump
  end

  def render_next_jump
    t = 0
    x = s.grasshopper.x + CAT_SIZE / 2
    y = s.grasshopper.y + CAT_SIZE / 2
    dx = s.grasshopper.next_dx
    dy = s.grasshopper.next_dy

    0.upto(30) do |t|
      x += dx
      y += dy
      dy -= GRAVITY
      if hit_grid_side?(x,y,dx) || hit_piece?(x, y, dx)
        dx = -dx
        x += 2 * dx
      end
      o.primitives << { x: x, y: y, w: 2, h: 2, }.to_solid
    end

  end

  def calc
    return if rescued?
    if on_floor? && s.grasshopper.dy < 0
      s.grasshopper.jumping = false
      s.grasshopper.dx = 0
      s.grasshopper.dy = 0
      s.grasshopper.y = ((s.grasshopper.y - GRID_RECT.y).idiv(CELL_SIZE) + 1)* CELL_SIZE + GRID_RECT.y - 2
    else 
      s.grasshopper.y += s.grasshopper.dy
      s.grasshopper.dy -= GRAVITY
    end

    s.grasshopper.y = 720 if s.grasshopper.y < -CAT_SIZE

    s.grasshopper.x += s.grasshopper.dx

    if hit_grid_side? || hit_piece?
      s.grasshopper.dx = -1* s.grasshopper.dx
      s.grasshopper.x += 2 * s.grasshopper.dx
    end
  end

  def jump!
    s.grasshopper.dx = s.grasshopper.next_dx
    s.grasshopper.dy = s.grasshopper.next_dy
    s.grasshopper.next_dx = rnd8*2 - 8
    s.grasshopper.next_dy = rnd8 + 1
    s.grasshopper.x += s.grasshopper.dx
    s.grasshopper.y += s.grasshopper.dy
    s.grasshopper.jumping
  end

  def on_floor?(x = s.grasshopper.x, y = s.grasshopper.y, dx = s.grasshopper.dx)
    return true if y < -CELL_SIZE
    r,c = to_rc([x + CAT_SIZE / 2, y - GAP])
    return is_solid?(r,c)
  end

  def hit_grid_side?(x = s.grasshopper.x, y = s.grasshopper.y, dx = s.grasshopper.dx)
    x += dx
    if dx > 0 # moving right, check right bound
      x + CAT_SIZE > GRID_RECT.x + GRID_RECT.w
    else            # moving left, check lect bound
      x < GRID_RECT.x
    end
  end

  def hit_piece?(x = s.grasshopper.x, y = s.grasshopper.y, dx = s.grasshopper.dx)
    x += 2 * dx
    x += CAT_SIZE if dx > 0 
    r,c = to_rc([x, y + CAT_SIZE / 2])
    return is_solid?(r,c)
  end

  def rnd_dy
    rnd8 + 2
  end

  def rnd_dx
    rnd8 * 2 - 8
  end

  def rescued?
    s.grasshopper.eaten
  end

  def intersect?(rect)
    [s.grasshopper.x,s.grasshopper.y,CAT_SIZE, CAT_SIZE].intersect_rect?(rect)
  end
end