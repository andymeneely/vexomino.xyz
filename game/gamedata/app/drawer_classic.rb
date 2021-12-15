class DrawerClassic

  def initialize(args)
    @args = args
    @blocks = Array.new(3) { |i| Block.new(@args, i) }
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

  def render
    render_progress_bar
    @blocks.each { |b| b.render unless b.blank? }
  end

  def find_grabbed
    @blocks.find do |b|
      @args.inputs.mouse.position.inside_rect?(b.rect) && !b.blank?
    end
  end

  def input
    # nothin at this time
  end

  # In Classic Mode, we set the block to blank and clear
  # If all are blank, THEN we reset
  def drop!(block)
    block.blank = true
    if @blocks.all? { |b| b.blank? }
      @blocks.each { |b| b.another_one! }
    end
  end

  def render_progress_bar
    o.solids << PROGRESS_RECT + s.pallete[:empty]
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
  end

  def score_to_progress(i)
    (PROGRESS_RECT[2].to_f * i / s.max_score).clamp(0, PROGRESS_RECT[2])
  end

end