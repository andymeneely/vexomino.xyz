SQUARE_SIZE = 50
GAP = 2
CELL_SIZE = SQUARE_SIZE + GAP
HALF_CELL = CELL_SIZE / 2
BLOCK_SIZE = (SQUARE_SIZE+GAP) * 3
GRID_START_X = 300
GRID_START_Y = 120
GRID_RECT = [
    GRID_START_X + 0.5,
    GRID_START_Y + 0.5,
    (SQUARE_SIZE + GAP) * 9 - 1,
    (SQUARE_SIZE + GAP) * 9 - 1,
]
PROGRESS_RECT = [
    GRID_START_X,
    600,
    9 * CELL_SIZE,
    10
]
SHADOW_START_RECT = [
    GRID_START_X - SQUARE_SIZE / 2,
    GRID_START_Y - SQUARE_SIZE / 2 ,
    (SQUARE_SIZE + GAP) * 10,
    (SQUARE_SIZE + GAP) * 10
]
PALLETES = {
    classic: {
        empty:    [200, 200, 200],
        empty2:   [150, 150, 150],
        overlap:  [100, 100, 100],
        filled:   [63, 55, 201],
        scorable: [67, 97, 238],
    },
    forest: {
        empty:    [200, 200, 200],
        overlap:  [96, 108, 56],
        filled:   [40, 54, 24],
        scorable: [96, 108, 56],
    },
    boring: {
        empty:    [200, 200, 200],
        overlap:  [176, 137, 104],
        filled:   [127, 85, 57],
        scorable: [156, 102, 68],
    },
    flame: {
        empty:    [200, 200, 200],
        overlap:  [55, 6, 23],
        filled:   [106, 4, 15],
        scorable: [157, 2, 8],
    },
    charcoal: {
        empty:    [200, 200, 200],
        overlap:  [173, 181, 189],
        filled:   [73, 80, 87],
        scorable: [108, 117, 125],
    },
    purple: {
        empty:    [200, 200, 200],
        overlap:  [157, 78, 221],
        filled:   [60, 9, 108],
        scorable: [90, 24, 154],
    },

}
DEFAULT_PALLETE = PALLETES[:classic]
DRAWER_X = 50
DRAWER_Y = 100
PIECE_COORDS = [
    [ [0,0] ],
    [ [0,0], [1,0] ],
    [ [0,0], [0,1] ],
    [ [0,0], [1,0] ],
    [ [0,0], [1,1] ],
    [ [0,0], [1,0], [0,1] ],
    [ [1,0], [1,1], [0,1] ],
    [ [0,0], [1,0], [1,1] ],
    [ [0,0], [1,0], [2,0], [1,1] ],
    [ [0,0], [1,0], [2,0], [1,1] ],
    [ [0,0], [1,0], [0,1], [1,1] ],
    [ [0,0], [1,0], [2,0], [0,1], [1,1] ],
    [ [0,0], [2,0], [1,0], [0,1], [0,2] ],
    [ [0,0], [1,0], [1,1], [1,2], [0,2] ],
    [ [0,1], [1,0], [1,1], [1,2], [2,1] ],
    [ [0,0], [0,1], [0,2], [1,2], [2,1] ], # conway glider
]

CONWAY_MODE_TICKS = 5

FLASH_FADE = 10

MAX_SCORE_DEFAULT = 100.0