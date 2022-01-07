class Congrats
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

  def defaults
    s.congrats.birthday ||= -1000
  end

  def render
    if @args.tick_count < (s.congrats.birthday + 120)
      n = @args.tick_count % JOURNEY_PALLETE.size
      o.labels << CONGRATS
        .merge(JOURNEY_PALLETE[n][:filled])
    end
  end

  def now!
    s.congrats.birthday = @args.tick_count
  end
end