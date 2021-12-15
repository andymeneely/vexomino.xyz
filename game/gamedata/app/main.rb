require 'app/block.rb'
require 'app/constants.rb'
require 'app/conway.rb'
require 'app/drawer_classic.rb'
require 'app/drawer_zen.rb'
require 'app/menu.rb'

class Array
  def widen(t)
    new_self = Array.new(self)
    new_self.x -= t
    new_self.y -= t
    new_self.w += 2 * t
    new_self.h += 2 * t
    return new_self
  end
end

class Game

  def initialize(args)
    @args = args
    @menu = Menu.new(args, )
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
      s.grid = nil if s.grid.is_a? GTK::OpenEntity # fix weird reset bug
      build_str = "build %04d" % @args.gtk.read_file("data/build.txt").to_i

      o.static_borders << GRID_RECT
      o.static_borders << GRID_RECT.widen(1)

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
    s.block_drawer   ||= DrawerClassic.new(@args)
    s.grabbed_block  ||= nil
    s.debug_str      ||= nil
    s.mouse_offset_x ||= 0
    s.mouse_offset_y ||= 0
    s.dropping       ||= false
    s.can_drop       ||= false
    s.conway_mode    ||= false
    s.mode           ||= :classic
    s.mode_changing  ||= false
    s.score          ||= 0
    s.pre_score      ||= 0
    s.pallete        ||= DEFAULT_PALLETE
    s.max_score      ||= MAX_SCORE_DEFAULT
    s.flash_message  ||= nil
    s.undoing        ||= false
    s.undo_stack     ||= []
  end

  def render

    @menu.render

    # dark grey lines
    # o.solids << [
    #   GRID_RECT.x-1,
    #   GRID_RECT.y-2,
    #   GRID_RECT.w+2,
    #   GRID_RECT.h+2,
    #   s.pallete[:overlap][0],
    #   s.pallete[:overlap][1],
    #   s.pallete[:overlap][2],
    # ]

    s.grid.map_2d do |r,c,v|
      o.solids << ([
        c * (SQUARE_SIZE + GAP) + GRID_START_X,
        r * (SQUARE_SIZE + GAP) + GRID_START_Y,
        SQUARE_SIZE,
        SQUARE_SIZE,
        ] + s.pallete[v])
    end

    # Render the empties AGAIN but alternate cages
    # For cage darkening effect
    [[0,3], [3,0], [3,6], [6,3]].each do |(cage_r, cage_c)|
      (cage_r..cage_r+2).each do |r|
        (cage_c..cage_c+2).each do |c|
          if s.grid[r][c] == :empty
            o.solids << ({
              x: c * (SQUARE_SIZE + GAP) + GRID_START_X,
              y: r * (SQUARE_SIZE + GAP) + GRID_START_Y,
              w: SQUARE_SIZE,
              h: SQUARE_SIZE,
              r: 25,
              g: 25,
              b: 25,
              a: 75,
            })
          end
        end
      end
    end

    s.block_drawer.render


    # [X,Y,TEXT,SIZE,ALIGN,RED,GREEN,BLUE,ALPHA,FONT STYLE]
    o.labels << [0, 720, s.debug_str, 5, 0, 0, 0, 0]
    # o.labels << [0, 50, "%.01f" % $gtk.current_framerate, 2, 0, 0, 0, 0]



    # unless s.flash_message.nil?
    #   o.labels << s.flash_message
    #   s.flash_message[7] -= FLASH_FADE
    #   s.flash_message = nil if s.flash_message[7] < 0
    # end

  end

  def input
    if s.grabbed_block.nil?
      if click_or_tap?
        s.grabbed_block = s.block_drawer.find_grabbed
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

    $gtk.reset if i.keyboard.r
    s.conway_mode = true if i.keyboard.l
    s.conway_mode = false if i.keyboard.l && i.keyboard.shift

    s.pallete = PALLETES[:boring] if i.keyboard.j
    s.pallete = PALLETES[:forest] if i.keyboard.f
    s.pallete = PALLETES[:flame] if i.keyboard.g
    s.pallete = PALLETES[:charcoal] if i.keyboard.h
    s.pallete = PALLETES[:purple] if i.keyboard.k
    s.debug_str = "#{i.mouse.x}, #{i.mouse.y}" if i.keyboard.x

    @menu.input
    s.block_drawer.input
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
    # Clear out any overlaps to recalculate
    s.grid = s.grid.map {|row| row.map {|v| v == :overlap ? :empty : v }}
    s.grid = s.grid.map {|row| row.map {|v| v == :scorable ? :filled : v }}
    s.pre_score = 0

    if s.grabbed_block&.rect&.inside_rect?(SHADOW_START_RECT)
      drag_block
    end

    if s.mode_changing # we JUST clicked mode change, so trigger this once
      s.block_drawer = case s.mode
      when :classic
        DrawerClassic.new(@args)
      when :zen
        DrawerZen.new(@args)
      when :journey # for now
        DrawerClassic.new(@args)
      when :puzzle # for now
        DrawerClassic.new(@args)
      end
      s.mode_changing = false
    end

    clear_and_score
    attempt_conway(s)
    undo! if s.undoing

  end

  def drag_block
    (off_r, off_c) = find_cell_grid_overlap

    drop_cell_rcs = s.grabbed_block.coords.map do |(r,c)| # determine where we drop
      [off_r + r, off_c + c]
    end

    s.can_drop = drop_cell_rcs.all? do |(r,c)|
      s.grid.at(r)&.at(c) == :empty
    end

    if s.can_drop
      drop_cell_rcs.each do |(r,c)|
        s.grid[r][c] = :overlap
      end
      s.pre_score += s.grabbed_block.score
    end

    if s.dropping # actually drop the piece!
      # s.undo_stack.push(s) # not supported yet
      drop_cell_rcs.each { |(r,c)| s.grid[r][c] = :filled }
      s.dropping = false
      s.can_drop = false
      s.score += s.grabbed_block.score
      s.pre_score = 0
      s.grabbed_block.let_go!
      s.block_drawer.drop!(s.grabbed_block)
      s.grabbed_block = nil
    end
    check_scorable

    level_up if s.score >= s.max_score
  end

  def clear_and_score
    any_score = s.grid.any? { |row| row.any? { |v| v == :scorable } } &&
                s.grabbed_block.nil?
    if any_score
      each_rc do |r, c|
        s.grid[r][c] = :empty if s.grid[r][c] == :scorable
      end
      s.score += s.pre_score
      s.pre_score = 0
    end
  end

  # Iterate over rows and cols and check for full
  # If they are full,
  def check_scorable

    s.grid.each.with_index do |row, i|
      row_scorable = row.all? { |v| v == :filled || v == :scorable || v == :overlap}
      if row_scorable # yay! row filled
        s.grid[i] = s.grid[i].map { |v| v == :filled ? :scorable : v }
        s.pre_score += 20
        flash "+20"
      end
    end

    0.upto(8).each do |c|
      col_filled = 0.upto(8).all? do |r|
        s.grid[r][c] == :filled || s.grid[r][c] == :scorable || s.grid[r][c] == :overlap
      end
      if col_filled # yay! col filled
        0.upto(8).each do |r|
          s.grid[r][c] = :scorable if s.grid[r][c] == :filled
        end
        s.pre_score += 20
        flash "+20"
      end
    end

    # each 3x3 "cage"
    [0, 3, 6].each do |cage_r|
      [0, 3, 6].each do |cage_c|

        cage_scorable = true
        (cage_r..cage_r + 2).each do |r|
          (cage_c..cage_c + 2).each do |c|
            v = s.grid[r][c]
            cage_scorable &&= (v == :filled || v == :scorable || v == :overlap)
          end
        end

        if cage_scorable
          (cage_r..cage_r + 2).each do |r|
            (cage_c..cage_c + 2).each do |c|
              s.grid[r][c] = :scorable if s.grid[r][c] == :filled
            end
          end
          s.pre_score += 20
          flash "+20"
        end

      end
    end

    compliment_them(s.pre_score)

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

  def undo!
    s.undoing = false
    s.debug_str = "undo not supported yet!"
    # old_state = s.undo_stack.pop
    # These are the undoable properties
    # s.grid           = old_state.grid
    # s.block_drawer   = DrawerClassic.new(@args)
    # s.grabbed_block  = nil
    # # s.mouse_offset_x = 0
    # # s.mouse_offset_y = 0
    # s.dropping       = false
    # s.can_drop       = false
    # # s.conway_mode    = false
    # # s.mode           = :classic
    # s.mode_changing  = false
    # s.score          = old_state.score
    # s.pre_score      = old_state.pre_score
    # s.max_score      = old_state.max_score
    # s.flash_message  = nil
  end


  def to_rc(p)
    [
      (p[1] - GRID_START_Y).idiv(CELL_SIZE),
      (p[0] - GRID_START_X).idiv(CELL_SIZE),
    ]
  end

  def each_rc(&block)
    0.upto(8).each do |r|
      0.upto(8).each do |c|
        block.yield(r, c)
      end
    end
  end

  def flash(message)
    s.flash_message = [
      400,
      400,
      message,
      8, # size
      30,
      30,
      30,
      255
    ] if s.flash_message.nil?
  end

  def compliment_them(pre_score)
    case pre_score
    when 1..20
      flash [
        "Nice!",
        "Good job!",
        "Cleared!",
      ].sample
    when 21..40
      flash [
        "Boom.",
        "Excellent!",
        "Sweet!",
        "Awesome!",
      ].sample
    when 41..1000
      flash [
        "Kapow!",
        "Bazinga!",
      ].sample
    end
  end

  def level_up
    s.max_score *= 2.5
  end

end

def tick args
  $game ||= Game.new(args)
  $game.tick(args)
end

$gtk.reset
$game = nil
