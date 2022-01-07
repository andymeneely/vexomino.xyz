class Classic

  attr_reader :blocks

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

  def init
  end

  def defaults
    
  end

  def render_ui
    render_progress_bar
  end

  def render
    @blocks.each { |b| b.render unless b.blank? }
  end

  def find_grabbed
    @blocks.find do |b|
      @args.inputs.mouse.position.inside_rect?(b.rect) && !b.blank? && b.possible
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
    pre_score_x = PROGRESS_RECT.x + score_to_progress(s.score)
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
  end

  def level_up!
  end

  def calc
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