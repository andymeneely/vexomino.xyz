SQUARE_SIZE = 50
GAP = 2
CELL_SIZE = SQUARE_SIZE + GAP
HALF_CELL = CELL_SIZE / 2
BLOCK_SIZE = (SQUARE_SIZE+GAP) * 3
GRID_START_X = 300
GRID_START_Y = 120
GRID_RECT = [
    GRID_START_X,
    GRID_START_Y,
    (SQUARE_SIZE + GAP) * 9,
    (SQUARE_SIZE + GAP) * 9,
]
PALLETE = {
    empty: [200, 200, 200],
    overlap: [100, 100, 100],
    filled: [20, 20, 255]
}
DRAWER_X = 50
DRAWER_Y = 100
PIECE_COORDS = [
    [ [1,1] ],
    [ [0,0], [0,1] ],
    [ [0,0], [1,0] ],
    [ [0,0], [1,0], [2,0], [1,1] ],
    [ [0,0], [1,0], [2,0], [0,1], [1,1] ],
    [ [0,0], [1,0], [2,0], [1,1] ],
    [ [1,1], [2,2] ],
    [ [2,0], [1,0], [0,0], [0,1], [0,2] ],
    [ [1,0], [2,0], [1,1], [2,1] ],
    [ [1,0], [0,0], [0,1] ],
    [ [1,2], [0,1], [0,2] ],
    [ [2,1], [2,2], [1,2] ],
    [ [1,0], [2,0], [2,1] ],
    [ [2,0], [1,0], [2,1], [2,2], [1,2] ],
]