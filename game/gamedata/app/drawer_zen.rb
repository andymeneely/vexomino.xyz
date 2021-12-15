require 'app/constants.rb'

class DrawerZen

  def initialize(args)
    @args = args
    @blocks = Array.new(3) { |i| Block.new(@args, i) }
    @shuffle_rects = 0.upto(@blocks.size - 1).map do | i|
      {
        x: DRAWER_X + BLOCK_SIZE,
        y: DRAWER_Y + i * (BLOCK_SIZE * 1.25) + BLOCK_SIZE / 3,
        w: SHUFFLE_BUTTON.w,
        h: SHUFFLE_BUTTON.h,
        path: 'sprites/shuffle.png'
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

  def render
    @shuffle_rects.each { |r| o.sprites << r }
    o.sprites << UNDO_BUTTON
    @blocks.each { |b| b.render unless b.blank? }
  end

  def find_grabbed
    @blocks.find do |b|
      i.mouse.position.inside_rect?(b.rect) && !b.blank?
    end
  end

  def input
    if i.mouse.button_left && i.mouse.position.inside_rect?(UNDO_BUTTON)
      s.undoing = true
    end


  end

  # In Zen Mode, we just send in another block every time
  # Never blank a block
  def drop!(block)
    block.another_one!
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