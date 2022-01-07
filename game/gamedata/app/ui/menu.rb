require 'app/constants.rb'

class Menu

  def initialize(args)
    @args = args

    @names = {
      classic: "Classic",
      zen:     "Zen",
      journey: "Journey",
      # puzzle: "Puzzle",
    }
    @rects = {}
    @names.each.with_index do |(k, v),i|
      @rects[k] = MENU_BUTTON
        .merge(x: MENU_BUTTON.x  - i * (MENU_BUTTON.w + MENU_BUTTON.gap))
        .merge(PALLETES[:classic][:empty])
    end
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

  def outer_stroke(rect)
    {
      x: rect.x-1,
      y: rect.y-1,
      w: rect.w+2,
      h: rect.h+2,
      r: rect.r,
      g: rect.g,
      b: rect.b
    }
  end

  def render
    @rects.each do |(k,rect)|
      fg_color = s.mode == k ? s.pallete[:empty] : s.pallete[:overlap]
      bg_color = s.mode == k ? s.pallete[:filled] : s.pallete[:empty]
      o.solids << rect.merge(bg_color)
      o.labels << rect.merge(fg_color).merge({
        text: @names[k],
        # 0.9 is text baseline correction
        y: rect.y + 0.9 * rect.h,
        x: rect.x + rect.w / 2,
        alignment_enum: 1
      })
    end
  end

  def input

    if i.mouse.button_left
      @rects.each do |(k,rect)|
        if i.mouse.position.inside_rect?(rect) && k != s.mode
          s.mode = k
          s.mode_changing = true
        end
      end
    end

  end


end