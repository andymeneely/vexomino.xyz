require 'app/block.rb'
require 'app/constants.rb'
require 'app/conway.rb'

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
    tick_zero
    defaults
    render
    input
    calc
  end

  def tick_zero
    if s.tick_count == 0
      @args.gtk.reset_sprite 'sprites/backdrop.png'
      build_str = "build %04d" % @args.gtk.read_file("data/build.txt").to_i

      o.static_labels << {
        x: 1220,
        y: 15,
        w: 100,
        text: build_str,
        r: 150,
        g: 150,
        b: 150,
        size_enum: -5
      }
    end
  end

  def defaults
    s.grid           ||= Array.new(9) { |_i| Array.new(9, :empty) }
    s.block_drawer   ||= Array.new(3) { |i| Block.new(@args, i) }
    s.grabbed_block  ||= nil
    s.debug          ||= nil
    s.mouse_offset_x ||= 0
    s.mouse_offset_y ||= 0
    s.dropping       ||= false
    s.can_drop       ||= false
    s.conway_mode    ||= false
    s.mode_title     ||= ""
  end

  def render

    o.sprites << {
      x: 0,
      y: 0,
      w: 1280,
      h: 720,
      path: 'sprites/backdrop.png'
    }

    s.grid.map_2d do |r,c,_v|
      o.solids << ([
        c * (SQUARE_SIZE + GAP) + GRID_START_X,
        r * (SQUARE_SIZE + GAP) + GRID_START_Y,
        SQUARE_SIZE,
        SQUARE_SIZE,
        ] + PALLETE[s.grid[r][c]])
    end

    o.labels << {
      x: 0, y: 700,
      text: s.debug,
      r: 0, g: 0, b: 0,
      size_enum: 10
    }

    o.labels << {
      x: 1100, y: 720,
      text: s.mode_title,
      r: 0, g: 0, b: 0,
      size_enum: 6
    }

    s.block_drawer.each { |b| b.render }
  end

  def input
    if s.grabbed_block.nil?
      if click_or_tap?
        s.grabbed_block = s.block_drawer.find do |b|
          i.mouse.position.inside_rect?(b.rect)
        end
        if s.grabbed_block
          s.mouse_offset_x = pointer_x - s.grabbed_block.x
          s.mouse_offset_y = pointer_y - s.grabbed_block.y
        end
      end
    else # block is already grabbed
      if click_or_tap?
        s.grabbed_block.x = pointer_x - s.mouse_offset_x
        s.grabbed_block.y = pointer_y - s.mouse_offset_y
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

    @args.gtk.reset if i.keyboard.r
    s.conway_mode = true if i.keyboard.l

    s.conway_mode = false if !i.finger_one.nil?

  end

  def click_or_tap?
    i.mouse.button_left || i.finger_one != nil
  end

  # "pointer" is either finger_one or mouse pointer
  def pointer_x
    if i.finger_one.nil?
      i.mouse.x
    else
      i.finger_one.x
    end
  end

  def pointer_y
    if i.finger_one.nil?
      i.mouse.y
    else
      i.finger_one.y
    end
  end


  def calc

    # Clear out any overlaps
    s.grid = s.grid.map {|row| row.map {|v| v == :overlap ? :empty : v }}

    if s.grabbed_block&.rect&.inside_rect?(SHADOW_START_RECT)
      (off_r, off_c) = find_cell_grid_overlap

      drop_cell_rcs = s.grabbed_block.coords.map do |(r,c)|
        [off_r + r, off_c + c]
      end

      s.can_drop = drop_cell_rcs.all? do |(r,c)|
        s.grid.at(r)&.at(c) == :empty
      end

      if s.can_drop
        drop_cell_rcs.each do |(r,c)|
          s.grid[r][c] = :overlap
        end
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

    attempt_conway(s)
  end

  def find_cell_grid_overlap
    x = s.grabbed_block.x
    y = s.grabbed_block.y
    c = [x + HALF_CELL, y + HALF_CELL]

    min_distance = 10000
    offset_rc = nil

    grid_ul = [(x - GRID_START_X).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_X + HALF_CELL,
               (y + CELL_SIZE - GRID_START_Y).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_Y + HALF_CELL]
    distance = g.distance(c, grid_ul)
    if distance < min_distance && grid_ul.inside_rect?(GRID_RECT)
      offset_rc = to_rc(grid_ul)
      min_distance = distance
    end

    grid_ur = [(x + CELL_SIZE - GRID_START_X).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_X + HALF_CELL,
               (y + CELL_SIZE - GRID_START_Y).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_Y + HALF_CELL]
    distance = g.distance(c, grid_ur)
    if distance < min_distance && grid_ur.inside_rect?(GRID_RECT)
      offset_rc = to_rc(grid_ur)
      min_distance = distance
    end

    grid_lr = [(x + CELL_SIZE - GRID_START_X).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_X + HALF_CELL,
               (y - GRID_START_Y).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_Y + HALF_CELL]
    distance = g.distance(c, grid_lr)
    if distance < min_distance && grid_lr.inside_rect?(GRID_RECT)
      offset_rc = to_rc(grid_lr)
      min_distance = distance
    end

    grid_ll = [(x - GRID_START_X).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_X + HALF_CELL,
              (y - GRID_START_Y).idiv(CELL_SIZE) * CELL_SIZE + GRID_START_Y + HALF_CELL]
    distance = g.distance(c, grid_ll)
    if distance < min_distance && grid_ll.inside_rect?(GRID_RECT)
      offset_rc = to_rc(grid_ll)
      min_distance = distance
    end

    # Debug collisions
    # o.lines << c + grid_lr
    # o.lines << c + grid_ll
    # o.lines << c + grid_ul
    # o.lines << c + grid_ur
    # o.borders << SHADOW_START_RECT

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
