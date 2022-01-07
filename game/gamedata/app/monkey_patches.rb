
class Array
  def widen(t)
    new_self = Array.new(self)
    new_self.x -= t
    new_self.y -= t
    new_self.w += 2 * t
    new_self.h += 2 * t
    return new_self
  end

  def full_h
    h.to_f + gap.to_f
  end

  def full_w
    puts binding.local_variables
    w.to_f + gap.to_f
  end

  def grid_dup
    map do |row| 
      row.map do |v|
        v
      end
    end
  end
end

def Hash 
  def full_h
    h.to_f + gap.to_f
  end

  def full_w
    puts binding.local_variables
    w.to_f + gap.to_f
  end
end