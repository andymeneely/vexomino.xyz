require 'app/main.rb'

class LevelAnnouncement
  
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

  def level_up!
    s.level_birthday = @args.tick_count
  end

  # Goes from 0 up to 1
  def easing
    @args.easing.ease(
      s.level_birthday,
      @args.tick_count,
      LEVEL_FADE,
      [:identity, :quad]
    )
  end

  def render
    if @args.tick_count < (s.level_birthday + LEVEL_FADE)
      dest_y = LEVEL_PROGRESS.y + LEVEL_PROGRESS.h * s.level  
      o.primitives << {
        x: LEVEL_ANNOUNCE.x * (1 - easing) + easing * LEVEL_PROGRESS.x,
        y: LEVEL_ANNOUNCE.y * (1 - easing) + easing * dest_y,
        text: "Level #{s.level}",
        size_enum: LEVEL_ANNOUNCE.size_enum * (1 - easing) +  easing * LEVEL_PROGRESS.size_enum,
      }.to_label(**s.pallete[:filled])
    end
    
  end

end