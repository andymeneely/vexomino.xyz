require 'app/block.rb'
require 'app/constants.rb'
require 'app/conway.rb'


require 'app/modes/journey.rb'
require 'app/modes/puzzle.rb'
require 'app/modes/classic.rb'
require 'app/modes/zen.rb'

require 'app/ui/menu.rb'
require 'app/ui/main_menu.rb'

require 'app/flash_messages.rb'
require 'app/monkey_patches.rb'
require 'app/level_announcement.rb'

require 'app/util.rb'

class Game

  def initialize(args)
    @args = args
    @main_menu = MainMenu.new(args)
    @modes = {
      journey: Journey.new(args),
      classic: Classic.new(args),
      zen: Zen.new(args),
      puzzle: Puzzle.new(args),
    }
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
    if s.mode == :main_menu
      @main_menu.tick
    else
      render
      input
      calc
    end
  end

  def tick_zero
    if s.tick_count == 0
      s.grid = nil if s.grid.is_a? GTK::OpenEntity # fix weird reset bug
      s.mode_specific = nil if s.mode_specific.is_a? GTK::OpenEntity 
      s.max_score = nil if s.max_score.is_a? GTK::OpenEntity 
      
      build_str = "build %04d" % @args.gtk.read_file("data/build.txt").to_i      
      o.static_labels << BUILD_STR.merge({text: build_str})
    end
  end

  def defaults
    s.grid           ||= Array.new(9) { |_i| Array.new(9, :empty) }
    s.mode_specific  ||= nil
    s.grabbed_block  ||= nil
    s.debug_str      ||= nil
    s.mouse_offset_x ||= 0
    s.mouse_offset_y ||= 0
    s.dropping       ||= false
    s.can_drop       ||= false
    s.conway_mode    ||= false
    s.mode           ||= :main_menu
    s.mode_changing  ||= false
    s.score          ||= 0
    s.pre_score      ||= 0
    s.gold           ||= 0
    s.pallete        ||= DEFAULT_PALLETE
    s.max_score      ||= MAX_SCORE_DEFAULT
    s.undoing        ||= false
    s.undo_stack     ||= []
    s.buying         ||= nil
    s.level          ||= 1
    s.combos         ||= 0
    s.messages       ||= FlashMessages.new(@args)
    s.drops          ||= 0
    s.total_score    ||= 0
    s.level_birthday ||= -1000
    s.congrats.birthday ||= -1000
    
    @modes[s.mode_specific]&.defaults
  end

  def render
    

    o.primitives << {
      x: GRID_RECT.x-1,
      y: GRID_RECT.y-1,
      w: GRID_RECT.w+2,
      h: GRID_RECT.h+2,
      r: 0, 
      g: 0,
      b: 0,
      primitive_marker: :border,
    }
    
    # dark grey lines
    # o.primitives << {
    #   x: GRID_RECT.x,
    #   y: GRID_RECT.y,
    #   w: GRID_RECT.w,
    #   h: GRID_RECT.h,
    #   primitive_marker: :solid,
    # }.merge(s.pallete[:overlap])
    s.mode_specific.render_ui

    s.grid.map_2d do |r,c,v|
      o.primitives << {
        x: c * (SQUARE_SIZE + GAP) + GRID_RECT.x,
        y: r * (SQUARE_SIZE + GAP) + GRID_RECT.y,
        w: SQUARE_SIZE,
        h: SQUARE_SIZE,
        r: s.pallete[v][:r],
        g: s.pallete[v][:g],
        b: s.pallete[v][:b],
        primitive_marker: :solid,
      }
    end

  # Render the empties AGAIN but alternate cages
  # For cage darkening effect
  [[0,3], [3,0], [3,6], [6,3]].each do |(cage_r, cage_c)|
    (cage_r..cage_r+2).each do |r|
      (cage_c..cage_c+2).each do |c|
        if s.grid[r][c] == :empty
          o.primitives << ({
            primitive_marker: :solid,
            x: c * (SQUARE_SIZE + GAP) + GRID_RECT.x,
            y: r * (SQUARE_SIZE + GAP) + GRID_RECT.y,
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

  o.labels << {
    x: 25,
    y: 100,
    size_enum: -3,
    text: "Run: #{s.total_score + s.score} Drops: #{s.drops}"
  }.merge(GREY)

  o.primitives << RESET.to_border
  o.primitives << RESET.to_label(y: RESET.y + 45, x: RESET.x + 8)

  s.mode_specific.render
  s.messages.render

  # [X,Y,TEXT,SIZE,ALIGN,RED,GREEN,BLUE,ALPHA,FONT STYLE]
  o.labels << [0, 720, s.debug_str, 5, 0, 0, 0, 0]
  
  # o.labels << [0, 50, "%.01f" % $gtk.current_framerate, 2, 0, 0, 0, 0]
  end

  def input
    if s.grabbed_block.nil?
      if click_or_tap?
        s.grabbed_block = s.mode_specific.find_grabbed
        if s.grabbed_block
          s.mouse_offset_x = pointer_x - s.grabbed_block.x
          s.mouse_offset_y = pointer_y - s.grabbed_block.y - GRAB_Y_OFFSET
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

    if i.mouse.click && i.mouse.position.inside_rect?(RESET)
      $gtk.reset(seed: rnd_int)
    end

    $gtk.reset(seed: rnd_int) if i.keyboard.r
    s.conway_mode = true if i.keyboard.l
    s.conway_mode = false if i.keyboard.l && i.keyboard.shift

    s.pallete = PALLETES[:boring] if i.keyboard.j
    s.pallete = PALLETES[:forest] if i.keyboard.f
    s.pallete = PALLETES[:flame] if i.keyboard.g
    s.pallete = PALLETES[:charcoal] if i.keyboard.h
    s.pallete = PALLETES[:purple] if i.keyboard.k
    s.score += 35 if i.keyboard.t
    s.debug_str = "#{i.mouse.x}, #{i.mouse.y}" if i.keyboard.x

    if i.keyboard.z
      r,c = to_rc([i.mouse.x, i.mouse.y])
      s.grid[r][c] = :filled
    end

    s.mode_specific.input
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
    if s.mode_changing # we JUST clicked mode change, so trigger this once
      # s.mode_specific = case s.mode
      #   when :classic
      #     Classic.new(@args)
      #   when :zen
      #     Zen.new(@args)
      #   when :journey # for now
      #     Journey.new(@args)
      #   when :puzzle # for now
      #     Puzzle.new(@args)
      # end
      s.mode_specific = @modes[s.mode]
      s.mode_changing = false
      s.grid = nil
      s.score = nil
      s.pre_score = nil
      s.undo_stack = nil
      s.mode_specific.init
      return
    end

    # Clear out any overlaps to recalculate
    s.grid = s.grid.map {|row| row.map {|v| v == :overlap ? :empty : v }}
    s.grid = s.grid.map {|row| row.map {|v| v == :scorable ? :filled : v }} 

    if s.grabbed_block&.inside_rect?(SHADOW_START_RECT)
      drag_block
    else 
      s.can_drop = false
      s.dropping = false
    end
    check_drop_possible

    s.mode_specific.calc
    attempt_conway(s)
    undo! if s.undoing
    level_up if s.score >= s.max_score
  end


  def drag_block
    (off_r, off_c) = find_cell_grid_overlap
    return if off_r.nil? || off_c.nil?

    drop_cell_rcs = s.grabbed_block.coords.map do |(r,c)| # determine where we drop
      [off_r + r, off_c + c]
    end

    s.can_drop = drop_cell_rcs.all? do |(r,c)|
      s.grid.at(r)&.at(c) == :empty
    end

    s.pre_score = 0

    if s.can_drop
      drop_cell_rcs.each do |(r,c)|
        s.grid[r][c] = :overlap
      end
      s.pre_score += s.grabbed_block.score
    end

    s.pre_score *= (s.combos + 1) # double on single score
    if s.dropping # actually drop the piece!
      save_for_undo!
      drop_cell_rcs.each { |(r,c)| s.grid[r][c] = :filled }
      s.dropping = false
      s.can_drop = false
      check_completed
      compliment_them
      s.mode_specific.drop!(s.grabbed_block)
      s.score += s.pre_score
      s.pre_score = 0
      s.combos = 0
      s.grabbed_block.let_go!
      s.grabbed_block = nil
      s.drops += 1
    else 
      check_completed
    end
    clear_scorable
    
  end

  # Iterate over rows and cols and check for full
  # If they are full, set to :scorable
  def check_completed
    s.combos = 0

    s.grid.each.with_index do |row, i|
      row_scorable = row.all? { |v| v == :filled || v == :scorable || v == :overlap}
      if row_scorable # yay! row filled
        s.grid[i] = s.grid[i].map { |v| v == :filled ? :scorable : v }
        s.combos +=1 
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
        s.combos += 1
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
          s.combos += 1
        end

      end
    end

  end
  
  def save_for_undo!
    s.undo_stack << { grid: s.grid.grid_dup }
    s.mode_specific.save_for_undo!
  end

  # Go over the grid and clear if there's any cells marked "scorable"
  def clear_scorable
    any_score = s.grid.any? { |row| row.any? { |v| v == :scorable } } &&
                s.grabbed_block.nil?
    if any_score
      s.mode_specific.clear_scorable
      each_rc do |r, c|
        s.grid[r][c] = :empty if s.grid[r][c] == :scorable
      end
    end
  end

  def find_cell_grid_overlap
    x = s.grabbed_block.x
    y = s.grabbed_block.y
    c = [x + HALF_CELL, y + HALF_CELL]

    min_distance = 10000
    offset_rc = nil

    grid_ul = [(x - GRID_RECT.x).idiv(CELL_SIZE) * CELL_SIZE + GRID_RECT.x + HALF_CELL,
               (y + CELL_SIZE - GRID_RECT.y).idiv(CELL_SIZE) * CELL_SIZE + GRID_RECT.y + HALF_CELL]
    distance = g.distance(c, grid_ul)
    if distance < min_distance && grid_ul.inside_rect?(GRID_RECT)
      offset_rc = to_rc(grid_ul)
      min_distance = distance
    end

    grid_ur = [(x + CELL_SIZE - GRID_RECT.x).idiv(CELL_SIZE) * CELL_SIZE + GRID_RECT.x + HALF_CELL,
               (y + CELL_SIZE - GRID_RECT.y).idiv(CELL_SIZE) * CELL_SIZE + GRID_RECT.y + HALF_CELL]
    distance = g.distance(c, grid_ur)
    if distance < min_distance && grid_ur.inside_rect?(GRID_RECT)
      offset_rc = to_rc(grid_ur)
      min_distance = distance
    end

    grid_lr = [(x + CELL_SIZE - GRID_RECT.x).idiv(CELL_SIZE) * CELL_SIZE + GRID_RECT.x + HALF_CELL,
               (y - GRID_RECT.y).idiv(CELL_SIZE) * CELL_SIZE + GRID_RECT.y + HALF_CELL]
    distance = g.distance(c, grid_lr)
    if distance < min_distance && grid_lr.inside_rect?(GRID_RECT)
      offset_rc = to_rc(grid_lr)
      min_distance = distance
    end

    grid_ll = [(x - GRID_RECT.x).idiv(CELL_SIZE) * CELL_SIZE + GRID_RECT.x + HALF_CELL,
              (y - GRID_RECT.y).idiv(CELL_SIZE) * CELL_SIZE + GRID_RECT.y + HALF_CELL]
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

  # Check over each block and see if it can be dropped SOMEWHERE
  def check_drop_possible
    blocks = s.mode_specific.blocks
    blocks.each do |b|
      b.possible = false
      each_rc do |r,c|
        drop_coords = b.coords.map { |br, bc| [r + br, c + bc] }
        b.possible ||= drop_coords.all? do |drop_r, drop_c|
          cell = s.grid.at(drop_r)&.at(drop_c)
          cell == :empty || cell == :overlap
        end
      end unless b.blank?
    end
  end

  def undo!
    s.undoing = false
    if s.undo_stack.any?
      s.grid = s.undo_stack.pop[:grid]
      s.mode_specific.undo! # FIXME  
    end
  end


  def to_rc(p)
    [
      (p[1] - GRID_RECT.y).idiv(CELL_SIZE),
      (p[0]  - GRID_RECT.x).idiv(CELL_SIZE),
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
    s.messages.flash(message)
  end

  def compliment_them
    compliment = ""
    compliment += "+#{s.pre_score} " unless s.mode == :zen
    compliment += " Combo x#{s.combos}! " if s.combos > 1
    case s.pre_score
    when 50..70
      compliment += [
        "Nice!",
        "Good job!",
        "Cleared!",
        "Well done!"
      ].sample
    when 71..120
      compliment += [
        "Zot!",
        "Boom.",
        "Excellent!",
        "Sweet!",
        "Awesome!",
        "Huzzah!",
      ].sample
    when 120..1000
      compliment += [
        "Kapow!",
        "Bazinga!",
      ].sample
    end
    flash compliment  
  end

  def level_up
    s.level += 1
    s.total_score += s.score
    s.score = (s.score - s.max_score).to_i
    s.max_score = (s.max_score * LEVEL_UP_FACTOR).to_i
    s.mode_specific.level_up!

    # Old way: always show your total score, progress bar just shrinks
    # new_max = MAX_SCORE_DEFAULT
    # s.level.times { new_max *= LEVEL_UP_FACTOR } # mruby doesn't have pow?
    # s.max_score += new_max
  end

end

def tick args
  $game ||= Game.new(args)
  $game.tick(args)
end

$gtk.reset
$game = nil
