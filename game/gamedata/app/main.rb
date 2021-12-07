require 'app/constants.rb'
require 'app/block.rb'

class Game

  def initialize(args)
    @args = args
  end

  def s
    @args.state
  end

  def o 
    @args.outputs
  end 

  def i 
    @args.inputs
  end

  def g
    @args.geometry
  end

  def tick args
    defaults 
    render 
    input
    calc
  end

  def defaults
    s.grid          ||= Array.new(9) { |_i| Array.new(9, :empty) }
    s.block_drawer  ||= Array.new(3) { |i| Block.new(@args, i) }
    s.grabbed_block ||= nil
    s.debug         ||= nil
    s.mouse_offset_x ||= 0
    s.mouse_offset_y ||= 0
  end
  
  def render 
    
    0.upto(8).each do |r|
      0.upto(8).each do |c| 
        o.solids << ([
          c * (SQUARE_SIZE + GAP) + GRID_START_X,
          r * (SQUARE_SIZE + GAP) + GRID_START_Y,
          SQUARE_SIZE,
          SQUARE_SIZE,
      ] + PALLETE[s.grid[r][c]])
      end
    end

    o.labels << {
      x: 0, y: 700, 
      text: s.debug,
      r: 0, g: 0, b: 0,
      size_enum: 10
    }

    o.borders << {
      x: GRID_RECT[0],
      y: GRID_RECT[1],
      w: GRID_RECT[2],
      h: GRID_RECT[3],
      r: 50,
      g: 50,
      b: 50
    }

    s.block_drawer.each { |b| b.render }
  end
  
  def input
    s.debug = s.block_drawer.first.rect
    if s.grabbed_block.nil?
      if i.mouse.button_left # grab a block
        s.grabbed_block = s.block_drawer.find do |b| 
          i.mouse.position.inside_rect? b.rect
        end
        if s.grabbed_block
          s.mouse_offset_x = i.mouse.x - s.grabbed_block.x
          s.mouse_offset_y = i.mouse.y - s.grabbed_block.y
        end
      end
    else # block is already grabbed
      if i.mouse.button_left
        s.grabbed_block.x = i.mouse.x - s.mouse_offset_x
        s.grabbed_block.y = i.mouse.y - s.mouse_offset_y
      else 
        if s.can_drop
          s.can_drop = false
          s.dropping = true 
        else 
          s.grabbed_block.let_go!
          s.grabbed_block = nil
        end
      end
    end

    @args.gtk.reset if i.keyboard.p
      
  end 
  
  def calc

    # Clear out any overlaps
    s.grid = s.grid.map {|row| row.map {|v| v == :overlap ? :empty : v }}
    
    if s.grabbed_block&.rect&.inside_rect?(GRID_RECT)
      (off_r, off_c) = find_cell_grid_overlap(s.grabbed_block.x, s.grabbed_block.y)
      
      drop_cell_rcs = s.grabbed_block.coords.map do |(r,c)|
        [off_r + r, off_c + c]
      end

      s.can_drop = drop_cell_rcs.none? { |(r,c)| s.grid[r][c] == :filled }
      if s.can_drop 
        drop_cell_rcs.each { |(r,c)| s.grid[r][c] = :overlap }
      end

      if s.dropping # actually drop the piece!
        drop_cell_rcs.each { |(r,c)| s.grid[r][c] = :filled }
        s.dropping = false 
        s.grabbed_block.let_go!
        s.grabbed_block.another_one!
        s.grabbed_block = nil
      end
    end

    
    

    s.grid.each.with_index do |row, i|
      if (row.all? { |cell| cell == :filled })
        s.grid[i] = Array.new(9, :empty)
      end
    end
     

  end

  def find_cell_grid_overlap(x,y)
    # center of square
    c = [s.grabbed_block.x + HALF_CELL, s.grabbed_block.y + HALF_CELL]
    x = s.grabbed_block.x
    y = s.grabbed_block.y
    
    # grid_square centers 
    grid_ul = [(x - GRID_START_X).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_X + HALF_CELL, 
               (y + CELL_SIZE - GRID_START_Y).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_Y + HALF_CELL]
    min_distance = g.distance(c, grid_ul)
    offset_rc = to_rc(grid_ul)

    grid_ur = [(x + CELL_SIZE - GRID_START_X).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_X + HALF_CELL, 
               (y + CELL_SIZE - GRID_START_Y).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_Y + HALF_CELL]
    distance = g.distance(c, grid_ur)
    if distance < min_distance
      offset_rc = to_rc(grid_ur)
      min_distance = distance
    end

    grid_lr = [(x + CELL_SIZE - GRID_START_X).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_X + HALF_CELL, 
               (y - GRID_START_Y).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_Y + HALF_CELL]
    distance = g.distance(c, grid_lr)
    if distance < min_distance
      offset_rc = to_rc(grid_lr)
      min_distance = distance
    end

    grid_ll = [(x - GRID_START_X).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_X + HALF_CELL, 
               (y - GRID_START_Y).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_Y + HALF_CELL]
    distance = g.distance(c, grid_ll)
    if distance < min_distance
      offset_rc = to_rc(grid_ll)
      min_distance = distance
    end
    
    return offset_rc
  end

  
  def to_rc(p)
    [
      (p[1] - GRID_START_Y).idiv(CELL_SIZE),
      (p[0] - GRID_START_X).idiv(CELL_SIZE),
    ]  
  end

end

def tick args
  $game ||= Game.new(args)
  $game.tick(args)
end

$gtk.reset
$game = nil
