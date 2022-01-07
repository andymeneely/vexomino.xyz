
class FlashMessages

  def initialize(args)
    @args = args
    @messages = []
  end

  def o
    @args.outputs
  end

  def i
    @args.inputs
  end

  def s
    @args.state
  end

  def flash(msg)
    @messages << {
      birthday: @args.tick_count,
      label: {
        x: i.mouse.x,
        y: FLASH_Y,
        text: msg,
        size_enum: 10,    
      }.merge(s.pallete[:filled])
    }
    
  end

  def render
    @messages.each do |m|
      m[:label].a = eased_alpha(m.birthday)
      o.labels << m[:label]
    end
    @messages.reject! {|m| s.tick_count > (m[:birthday] + FLASH_FADE) }
  end

  def eased_alpha(birthday)
    255.0 - 255.0 * @args.easing.ease(birthday,
                            @args.tick_count,
                            FLASH_MESSAGE_FADE,
                            :quad)
  end

  def serialize
    { messages: @messages }
  end

  def inspect
    serialize
  end

  def to_s
    serialize.to_s
  end
end