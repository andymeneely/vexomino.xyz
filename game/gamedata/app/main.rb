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
      build_str = "build %04d" % @args.gtk.read_file("data/build.txt").to_i

      # o.static_borders << GRID_RECT
      # o.static_borders << [
      #   GRID_RECT[0]-1,
      #   GRID_RECT[1]-1,
      #   GRID_RECT[2]+2,
      #   GRID_RECT[3]+2,
      # ]

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
    s.score          ||= 0
    s.pre_score      ||= 0
    s.done           ||= false
    s.pallete        ||= DEFAULT_PALLETE
    s.max_score      ||= MAX_SCORE_DEFAULT
    s.flash_message  ||= nil
  end

  def render

    # if !s.done && s.score > CELL_SIZE * 9
    #   s.done = true
    #   s.conway_mode = true
    # end

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

    # [X,Y,TEXT,SIZE,ALIGN,RED,GREEN,BLUE,ALPHA,FONT STYLE]
    o.labels << [1100, 720, s.mode_title, 6, 0, 0, 0, 0]
    o.labels << [0, 720, s.debug, 5, 0, 0, 0, 0]
    # o.labels << [0, 50, "%.01f" % $gtk.current_framerate, 2, 0, 0, 0, 0]

    o.borders << PROGRESS_RECT + s.pallete[:filled]
    o.solids << [
      PROGRESS_RECT.x, PROGRESS_RECT.y,
      score_to_progress(s.score), PROGRESS_RECT.h,
    ] + s.pallete[:filled]
    pre_score_x = PROGRESS_RECT.x + score_to_progress(s.score)
    o.solids << {
      x: pre_score_x,
      y: PROGRESS_RECT.y,
      w: score_to_progress(s.pre_score).clamp(0, PROGRESS_RECT.w + PROGRESS_RECT.x - pre_score_x),
      h: PROGRESS_RECT.h,
      r: s.pallete[:scorable][0],
      g: s.pallete[:scorable][1],
      b: s.pallete[:scorable][2]
    }

    s.block_drawer.each { |b| b.render }


    # unless s.flash_message.nil?
    #   o.labels << s.flash_message
    #   s.flash_message[7] -= FLASH_FADE
    #   s.flash_message = nil if s.flash_message[7] < 0
    # end

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

    $gtk.reset if i.keyboard.r
    s.conway_mode = true if i.keyboard.l
    s.conway_mode = false if i.keyboard.l && i.keyboard.shift

    s.pallete = PALLETES[:boring] if i.keyboard.c
    s.pallete = PALLETES[:forest] if i.keyboard.f
    s.pallete = PALLETES[:flame] if i.keyboard.g
    s.pallete = PALLETES[:charcoal] if i.keyboard.h
    s.pallete = PALLETES[:purple] if i.keyboard.k

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
        s.pre_score += s.grabbed_block.score
      end

      if s.dropping # actually drop the piece!
        drop_cell_rcs.each { |(r,c)| s.grid[r][c] = :filled }
        s.dropping = false
        s.score += s.grabbed_block.score
        s.pre_score = 0
        s.grabbed_block.let_go!
        s.grabbed_block.another_one!
        s.grabbed_block = nil
      end
      check_scorable

      level_up if s.score >= s.max_score

    end

    clear_and_score
    attempt_conway(s)
    s.mode_title = ""
    s.mode_title = "Conway Mode" if s.conway_mode

    s.score = 950 if i.keyboard.p
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

  def score_to_progress(i)
    (PROGRESS_RECT[2].to_f * i / s.max_score).clamp(0, PROGRESS_RECT[2])
  end

  def  flash(message)
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
