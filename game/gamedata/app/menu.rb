require 'app/constants.rb'

class Menu

  MENU_BUTTON = {
    x: 950,
    y: 475,
    w: 200,
    h: 75,
  }

  MENU_BUTTON_GAP = 25

  def initialize(args)
    @args = args

    @names = {
      classic: "Classic",
      zen:     "Zen",
      journey: "Journey",
      puzzle: "Puzzle",
    }
    @rects = {}
    @names.each.with_index do |(k, v),i|
      @rects[k] = {
        x: MENU_BUTTON.x,
        y: MENU_BUTTON.y - i * (MENU_BUTTON.h + MENU_BUTTON_GAP),
        w: MENU_BUTTON.w,
        h: MENU_BUTTON.h,
        r: PALLETES[:classic][:empty][0],
        g: PALLETES[:classic][:empty][1],
        b: PALLETES[:classic][:empty][2],
        size_enum: 10,
      }
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

    empty = {
      r: s.pallete[:empty][0],
      g: s.pallete[:empty][1],
      b: s.pallete[:empty][2]
    }
    filled = {
      r: s.pallete[:filled][0],
      g: s.pallete[:filled][1],
      b: s.pallete[:filled][2]
    }
    overlap = {
      r: s.pallete[:overlap][0],
      g: s.pallete[:overlap][1],
      b: s.pallete[:overlap][2]
    }

    @rects.each do |(k,rect)|
      fg_color = s.mode == k ? empty : overlap
      bg_color = s.mode == k ? filled : empty
      o.solids << rect.merge(bg_color)
      o.labels << rect.merge(fg_color).merge({
        text: @names[k],
        # 0.8 is text baseline correction
        y: rect.y + rect.h / 2 + MENU_BUTTON_GAP * 0.8,
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