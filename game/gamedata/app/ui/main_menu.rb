require 'app/constants.rb'
require 'app/main.rb'

class MainMenu
  def initialize(args)
    @args = args

    @menu_rects = MENU_OPTIONS.map.with_index do |(mode, name), n|
      MAIN_MENU.merge( 
        y: MAIN_MENU.y + n * (MAIN_MENU.h + MAIN_MENU.gap),
        mode: mode,
        name: name,
        text: name,
      )
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
  
  def tick
    render
    input
    calc
  end

  def render
    @menu_rects.each do |rect|
      o.primitives << rect.to_border( **s.pallete[:filled] )
      o.primitives << rect.to_label(
        y: rect.y + 0.85 * rect.h,
        x: rect.x + 0.5 * rect.w,
        **s.pallete[:filled] 
      )
    end
  end

  def input
    @menu_rects.each do |rect|
      if i.mouse.click && i.mouse.position.inside_rect?(rect)
        s.mode = rect.mode
        s.mode_changing = true
      end
    end
  end

  def calc
  end



end