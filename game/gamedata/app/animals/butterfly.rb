class Butterfly
  attr_sprite

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
  end

  def render
    o.primitives << {
      x: s.puzzle.butterfly.x,
      y: s.puzzle.butterfly.y,
      w: CAT_SIZE,
      h: CAT_SIZE,
      path: 'sprites/butterfly.png'
    }.to_sprite
    o.primitives << {
      x: s.puzzle.butterfly.x,
      y: s.puzzle.butterfly.y,
      w: CAT_SIZE,
      h: CAT_SIZE,
    }.to_border
  end

  def calc 
    # s.puzzle.butterfly.x += s.puzzle.butterfly.dx
    # s.puzzle.butterfly.y += s.puzzle.butterfly.dy

    r,c = to_rc(s.puzzle.butterfly)
    
    if c < 0 || r < 0 || r > 8 || c > 8
      celebrate! unless s.puzzle.celebrating
      new_level! if done_celebrating?
    else # in the grid
      # if s.grid[r][c] 
      # s.puzzle.butterfly.dx = -s.puzzle.butterfly.dx 
      # end
    end
    
  end
end