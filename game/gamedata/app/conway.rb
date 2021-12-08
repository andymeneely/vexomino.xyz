def attempt_conway(s)
  if s.conway_mode && s.tick_count % CONWAY_MODE_TICKS == 0
    new_grid = Array.new(9) { |_i| Array.new(9, :empty) }
    s.grid.each.with_index do |row, r|
      row.each.with_index do |v, c|
        n = 0
        n+=1 if s.grid[(r + 1) % 9][(c + 1) % 9] == :filled
        n+=1 if s.grid[(r + 1) % 9][(c + 0) % 9] == :filled
        n+=1 if s.grid[(r + 1) % 9][(c - 1) % 9] == :filled

        n+=1 if s.grid[(r - 1) % 9][(c + 1) % 9] == :filled
        n+=1 if s.grid[(r - 1) % 9][(c + 0) % 9] == :filled
        n+=1 if s.grid[(r - 1) % 9][(c - 1) % 9] == :filled

        n+=1 if s.grid[(r + 0) % 9][(c - 1) % 9] == :filled
        n+=1 if s.grid[(r + 0) % 9][(c + 1) % 9] == :filled

        new_grid[r][c] = v
        new_grid[r][c] = :empty  if v == :filled && (n < 2 || n > 3)
        new_grid[r][c] = :filled if v == :empty  && n == 3
      end
    end
    s.grid = new_grid
    s.mode_title = "Conway Mode"
  end
end