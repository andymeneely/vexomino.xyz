require 'app/constants.rb'

class Zen

  attr_reader :blocks

  def initialize(args)
    @args = args
    @blocks = Array.new(3) { |i| Block.new(@args, i) }
    @undo_stack = []
    @shuffle_rects = 0.upto(@blocks.size - 1).map do |i|
      {
        x: DRAWER_X + BLOCK_SIZE,
        y: DRAWER_Y + i * (BLOCK_SIZE * 1.25) + BLOCK_SIZE / 3,
        w: SHUFFLE_BUTTON.w,
        h: SHUFFLE_BUTTON.h,
        path: 'sprites/shuffle.png',
        block: @blocks[i]
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

  def init
  end

  def defaults
  end

  def render_ui
    @shuffle_rects.each { |r| o.sprites << r }
    o.sprites << UNDO_BUTTON if @undo_stack.any?
  end

  def undo!
    @blocks = @undo_stack.pop[:blocks] if @undo_stack.any?
  end

  def save_for_undo!
    @undo_stack << { blocks: @blocks.map { |b| b.dup } }
  end

  def render
    @blocks.each { |b| b.render unless b.blank? }
  end

  def find_grabbed
    @blocks.find do |b|
      i.mouse.position.inside_rect?(b.rect) && !b.blank?
    end
  end

  def input
    if i.mouse.click && i.mouse.position.inside_rect?(UNDO_BUTTON)
      s.undoing = true
    end
    
    if i.mouse.click && 
      (shuf = @shuffle_rects.find {|r| i.mouse.position.inside_rect?(r)})
      shuf.block.another_one!
    end
  end

  # In Zen Mode, we just send in another block every time
  # Never blank a block
  def drop!(block)
    block.another_one!
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