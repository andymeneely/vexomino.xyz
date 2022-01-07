def rnd8
  (@rng.rand() * 9).to_i
end

def rnd_int
  (rand() * 1000000).to_i
end

def rnd_jump
  (@rng.rand() * 12).to_i - 6
end

def to_rc(p)
  [ (p.y - GRID_RECT.y).idiv(CELL_SIZE),
    (p.x  - GRID_RECT.x).idiv(CELL_SIZE), ]
end

def is_solid?(r,c)
  r >= 0 && r <= 8 && c >= 0 && c <= 8 && 
    (s.grid[r][c] == :filled || s.grid[r][c] == :scorable)
end

def is_empty?(r,c)
  r >= 0 && r <= 8 && c >= 0 && c <= 8 && 
    (s.grid[r][c] == :empty || s.grid[r][c] == :overlap)
end

def to_xy(r,c)
  [ c * CELL_SIZE + GRID_RECT.x,
    r * CELL_SIZE + GRID_RECT.y ]
end