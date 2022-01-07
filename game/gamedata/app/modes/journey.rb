require 'app/animations/congrats.rb'

class Journey

  attr_reader :blocks

    def initialize(args)
      @args = args
      @drawer_size = JOURNEY_DRAWER_START
      @blocks = Array.new(@drawer_size) { |i| Block.new(@args, i) }
      @rng = Random.new()
      @level_announcement = LevelAnnouncement.new(@args)
      @congrats = Congrats.new(@args)
      clear_state!
      defaults
      new_coin!
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

    def defaults
      s.gold ||= 0
      ITEMS.each do |(k,v)|
        s.costs[k] = v[:cost]
      end if s.costs.nil?
      @congrats.defaults
    end

    def init
      s.pallete = JOURNEY_PALLETE[0]
    end
  
    def render_ui
      render_progress_bar
      ITEMS.each do |(k, h)|
        unless s.unlocked[k]
          can_afford = s.gold >= s.costs[k]
          
          if can_afford && i.mouse.position.inside_rect?(h)
            o.primitives << h.to_solid(**s.pallete[:empty])  
          end

          o.primitives << h.to_border(**GREY)

          o.primitives << h.to_label(
            x: h.x + h.label_dx,
            y: h.y + h.label_dy,
            **(can_afford ? s.pallete[:filled] : GREY)
          )
          
          o.primitives << h.to_label(
            x: h.x + h.label_dx + 20,
            y: h.y + h.label_dy - 20,
            text: "#{s.costs[k]}g",
            **(can_afford ? GOLD_FG : GREY)
          )

          o.primitives << h.to_border(**GREY)
        end
      end
      render_level_progress
    end

    def render_level_progress
      (1..20).each do |lvl|
        label_color = s.level >= lvl ? :filled : :empty
        label_color = :empty if s.level == lvl && @args.tick_count < s.level_birthday + LEVEL_FADE
        o.primitives << LEVEL_PROGRESS.to_label(
          text: "Level #{lvl}",
          y: lvl * LEVEL_PROGRESS.h + LEVEL_PROGRESS.y,
          **s.pallete[label_color]
        )
      end
    end

    def clear_state!
      s.gold = nil
      s.coins = nil
      s.coin_value = nil
      s.coin_plus_one_cost = nil
      s.costs = nil
    end

    def defaults
      s.gold ||= 0
      s.coins ||= Array.new(9) { |_i| Array.new(9, 0) }
      ITEMS.each do |(k,v)| 
        s.unlocked[k] = false
        s.costs[k] = v[:cost]
      end if s.unlocked.nil?
      s.coin_value ||= 1
    end

    def rnd8
      (@rng.rand() * 9).to_i
    end

    def new_coin!
      10.times do 
        r = rnd8
        c = rnd8
        if s.coins[r][c] == 0
          s.coins[r][c] = s.coin_value
          break
        end
      end
    end
  
    def render
      o.sprites << JOURNEY_GOLD
      o.labels << JOURNEY_GOLD_TXT.merge({text: s.gold}).merge(GOLD_FG)

      xy_offset = (SQUARE_SIZE - COIN.w) / 2.0
      s.coins.map_2d do |r,c,v|
        if v > 0
          o.primitives << COIN.merge({
            x: c * (SQUARE_SIZE + GAP) + GRID_RECT.x + xy_offset,
            y: r * (SQUARE_SIZE + GAP) + GRID_RECT.y + xy_offset,
          }).sprite
          o.primitives << COIN.merge({
            x: c * (SQUARE_SIZE + GAP) + GRID_RECT.x + xy_offset + 14,
            y: r * (SQUARE_SIZE + GAP) + GRID_RECT.y + xy_offset + 27,
            text: v
          }).merge(GOLD_FG).label
        end
      end
      o.primitives << LEVEL.merge(s.pallete[:filled]).merge(text: "Level #{s.level}").label
      @blocks.each { |b| b.render unless b.blank? }

      @level_announcement.render
      @congrats.render
    end
  
    def find_grabbed
      @blocks.find do |b|
        @args.inputs.mouse.position.inside_rect?(b.rect) && !b.blank?
      end
    end
  
    def input
      if i.mouse.click 
        ITEMS.each do |(k,rect)|
          if i.mouse.position.inside_rect?(rect)
            s.buying = k
          end
        end
      end
      s.gold += 1 if i.keyboard.p 
    end
  
    # In Journey Mode, we act like Classic unless we unlock Zen
    def drop!(block)
      if s.unlocked.refresh
        block.another_one!
      else 
        block.blank = true
        if @blocks.all? { |b| b.blank? }
          @blocks.each { |b| b.another_one! }
        end
      end
      s.combos.times do 
        new_coin!
        new_coin! if s.unlocked.coins_for_combos
      end
    end
  
    def save_for_undo!
      # nothin for now
    end
  
    def render_progress_bar
      o.solids << {
        x: PROGRESS_RECT.x,
        y: PROGRESS_RECT.y,
        w: PROGRESS_RECT.w,
        h: PROGRESS_RECT.h,
      }.merge(s.pallete[:empty])
      o.solids << {
        x: PROGRESS_RECT.x, y: PROGRESS_RECT.y,
        w: score_to_progress(s.score), h: PROGRESS_RECT.h,
      }.merge(s.pallete[:filled]) 
      pre_score_x = PROGRESS_RECT.x + score_to_progress(s.score) + 1 # tiny gap
      o.solids << {
        x: pre_score_x,
        y: PROGRESS_RECT.y,
        w: score_to_progress(s.pre_score).clamp(0, PROGRESS_RECT.w + PROGRESS_RECT.x - pre_score_x),
        h: PROGRESS_RECT.h,
      }.merge(s.pallete[:scorable])
      o.labels << PROGRESS_LABEL.merge(text: s.score).merge(s.pallete[:filled])
      o.labels << PROGRESS_LABEL
        .merge(text: "+#{s.pre_score}", x: PROGRESS_LABEL.x + PROGRESS_LABEL.w)
        .merge(s.pallete[:scorable]) unless s.pre_score == 0
    end
  
    def score_to_progress(i)
      (PROGRESS_RECT[2].to_f * i / s.max_score).clamp(0, PROGRESS_RECT[2])
    end

    def clear_scorable
      each_rc do |r, c|
        if s.grid[r][c] == :scorable && s.coins[r][c] > 0
          s.gold += s.coins[r][c]
          s.coins[r][c] = 0
        end
      end
    end

    def each_rc(&block)
      0.upto(8).each do |r|
        0.upto(8).each do |c|
          block.yield(r, c)
        end
      end
    end

    def calc
      buy_item unless s.buying.nil?
    end

    def buy_item 
      item = s.buying
      s.buying = nil # only do this once
      cost = s.costs[item]
      return unless cost <= s.gold && !s.unlocked[item]
      case item
        when :second_piece
          @blocks << Block.new(@args, @blocks.size)
          s.unlocked[item] = true
        when :third_piece
          @blocks << Block.new(@args, @blocks.size)
          s.unlocked[item] = true
        when :coins_plus_one
          s.coin_value += 1
          s.costs.coins_plus_one += s.costs.coins_plus_one - 2
          refresh_coins!
        when :coins_2x
          s.coin_value *= 2
          s.unlocked[item] = true
          refresh_coins!
        when :coins_3x
          s.coin_value *= 3
          s.unlocked[item] = true
          refresh_coins!
        when :coins_for_combos
          s.unlocked[item] = true
        when :refresh
          s.unlocked[item] = true
        when :refresh_all
          s.costs[item] *= 2
          @blocks.each { |b| b.another_one! }
        when :single
          s.costs[item] *= 2
          @blocks.first.coords = [ [0,0] ]
          @blocks.first.blank = false
      end
      s.gold -= cost
      COST_COHORT.each do |k|
        s.costs[k] *= COHORT_INCREASE_FACTOR unless s.unlocked[k]
        s.costs[k] = s.costs[k].to_i
      end if COST_COHORT.include? item
    end

    def refresh_coins!
      each_rc do |r,c|
        s.coins[r][c] = (s.coins[r][c] == 0) ? 0 : s.coin_value
      end
    end

    def level_up!
      if s.level <= 20
        s.level_birthday = @args.tick_count
        s.pallete = JOURNEY_PALLETE[(s.level - 1) % JOURNEY_PALLETE.size]
      else 
        @congrats.now!
        s.level_birthday = @args.tick_count
      end
    end
  
    def serialize
      {}
    end
  
    def inspect
      serialize.to_s
    end
  
    def to_s
      serialize.to_s
    end
  
  end