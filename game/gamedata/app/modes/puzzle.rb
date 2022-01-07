require 'app/constants.rb'
require 'app/main.rb'
require 'app/util.rb'

require 'app/animals/cat.rb'
require 'app/animals/butterfly.rb'
require 'app/animals/grasshopper.rb'

class Puzzle

  attr_reader :blocks

  def initialize(args)
    @args = args
    @blocks = Array.new(3) { |i| Block.new(@args, i) }
    @cat = Cat.new(args)
    @grasshopper = Grasshopper.new(args)
    @butterfly = Butterfly.new(args)
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
    
    @cat.defaults
    s.puzzle.celebrate_until ||= -1000
    s.puzzle.celebrating     ||= false
    s.puzzle.butterfly.x     ||= 500
    s.puzzle.butterfly.y     ||= 500
    s.puzzle.butterfly.dx    ||= 1.5
    s.puzzle.butterfly.dy    ||= 1.25

    @cat.defaults
    @grasshopper.defaults
    
  end

  def init 
    new_level!
  end

  def render_ui
  end

  def undo!
    # nothin!
  end

  def save_for_undo!
    #nothin!
  end

  def render
    @cat.render
    @grasshopper.render
    # @butterfly.render

    @blocks.each { |b| b.render unless b.blank? }

    if s.puzzle.celebrating
      o.primitives << LEVEL_ANNOUNCE.to_label(
        text: "HOORAY!",
        a: 255.0 * @args.easing.ease(
          s.puzzle.celebrate_until - LEVEL_FADE,
          @args.tick_count,
          LEVEL_FADE,
          :flip)
      )
    end

  end

  def find_grabbed
    @blocks.find do |b|
      i.mouse.position.inside_rect?(b.rect) && !b.blank?
    end
  end

  def input
    # nothing
  end

  # In Puzzle Mode, we just send in another block every time
  # Never blank a block
  def drop!(block)
    block.another_one!
    @grasshopper.jump!
  end

  def clear_scorable
  end

  def level_up!
  end

  def new_level!
    s.puzzle.celebrating = false
    @cat.new_level!
    @grasshopper.new_level!

    s.puzzle.butterfly.x  = GRID_RECT.x + GRID_RECT.w / 2
    s.puzzle.butterfly.y  = GRID_RECT.y + GRID_RECT.h / 2
    s.puzzle.butterfly.dx = @args.rand() * 3 - 1.5
    s.puzzle.butterfly.dy = @args.rand() * 3 - 1.5

    s.grid = Array.new(9) { |_i| Array.new(9, :empty) }

    2.times do 
      9.times do |c|
        s.grid[rnd8][c] = :filled
      end
    end
  end

  def calc

    @cat.calc
    # @butterfly.calc
    @grasshopper.calc

    s.grasshopper.eaten = true if @grasshopper.intersect?(@cat.rect)

    if @cat.rescued? && @grasshopper.rescued?
      celebrate! unless s.puzzle.celebrating
      new_level! if done_celebrating?
    end
      
  end

  def celebrate!
    s.puzzle.celebrating = true
    s.puzzle.celebrate_until = @args.tick_count + LEVEL_FADE
  end

  def done_celebrating?
    s.puzzle.celebrating && s.tick_count > s.puzzle.celebrate_until
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