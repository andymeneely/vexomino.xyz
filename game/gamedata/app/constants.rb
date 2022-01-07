require 'app/main.rb'

SQUARE_SIZE = 50
GAP = 1
CELL_SIZE = SQUARE_SIZE + GAP
HALF_CELL = CELL_SIZE / 2
BLOCK_SIZE = (SQUARE_SIZE+GAP) * 3
GRID_RECT = [
  410.5,
  120.5,
  (SQUARE_SIZE + GAP) * 9 - 1,
  (SQUARE_SIZE + GAP) * 9 - 1,
]
PROGRESS_RECT = [
  GRID_RECT.x,
  600,
  9 * CELL_SIZE,
  10
]
PROGRESS_LABEL = {
  x: PROGRESS_RECT.x + PROGRESS_RECT.w + 20,
  y: PROGRESS_RECT.y + 15,
  w: 40,
  h: 20,
  size_enum: -1
}

GRAB_Y_OFFSET = 2 * CELL_SIZE

SHADOW_START_RECT = [
  GRID_RECT.x - SQUARE_SIZE / 2,
  GRID_RECT.y - SQUARE_SIZE / 2 ,
  (SQUARE_SIZE + GAP) * 10,
  (SQUARE_SIZE + GAP) * 10
]

RESET = {
  x: 1150, 
  y: 600,
  w: 2 * CELL_SIZE,
  h: CELL_SIZE,
  size_enum: 8,
  text: "Reset",
  r: 25,
  g: 25,
  b: 25,
}

PALLETES = {
  classic: {
      empty:    {r: 200, g: 200, b: 200},
      overlap:  {r: 100, g: 100, b: 100},
      filled:   {r: 50,  g: 82,  b: 198}, 
      scorable: {r: 67,  g: 97,  b: 238},
  },
  forest: {
      empty:    {r: 200, g: 200, b: 200},
      overlap:  {r: 96,  g: 108, b: 56},
      filled:   {r: 40,  g: 54,  b: 24},
      scorable: {r: 96,  g: 108, b: 56},
  },
  boring: {
      empty:    {r: 200, g: 200, b: 200},
      overlap:  {r: 176, g: 137, b: 104},
      filled:   {r: 127, g: 85,  b:  57},
      scorable: {r: 156, g: 102, b: 68},
  },
  flame: {
      empty:    {r: 200, g: 200, b: 200},
      overlap:  {r: 55,  g: 6,   b: 23},
      filled:   {r: 106, g: 4,   b: 15},
      scorable: {r: 157, g: 2,   b: 8},
  },
  charcoal: {
      empty:    {r: 200, g: 200, b: 200},
      overlap:  {r: 173, g: 181, b: 189},
      filled:   {r: 73,  g: 80,  b:  87},
      scorable: {r: 108, g: 117, b: 125},
  },
  purple: {
      empty:    {r: 200, g: 200, b: 200},
      overlap:  {r: 157, g: 78,  b: 221},
      filled:   {r: 60,  g: 9,   b: 108},
      scorable: {r: 90,  g: 24,  b: 154},
  },

}
DEFAULT_PALLETE = PALLETES[:classic]
DRAWER_GAP = 40
DRAWER_X = GRID_RECT.x - BLOCK_SIZE - CELL_SIZE
DRAWER_Y = GRID_RECT.y - DRAWER_GAP
PIECE_COORDS = [
  [ [0,0] ],
  [ [0,1], [1,0] ],
  [ [0,0], [0,1] ],
  [ [0,0], [1,0] ],
  [ [0,0], [1,1] ],
  [ [0,0], [1,0], [2,0] ],
  [ [0,0], [0,1], [0,2] ],
  [ [0,0], [1,0], [0,1] ],
  [ [1,0], [1,1], [0,1] ],
  [ [0,0], [1,0], [1,1] ],
  [ [0,0], [1,1], [2,2] ],
  [ [2,0], [1,1], [0,2] ],
  [ [2,1], [1,0], [0,1] ],
  [ [0,0], [1,1], [2,0] ],
  [ [0,0], [1,0], [2,0], [1,1] ],
  [ [0,1], [1,1], [2,1], [1,0] ],
  [ [0,0], [0,1], [0,2], [1,1] ],
  [ [1,0], [1,1], [1,2], [0,1] ],
  [ [0,0], [1,0], [0,1], [1,1] ],
  [ [0,0], [0,1], [1,1], [1,2] ],
  [ [1,0], [1,1], [0,1], [0,2] ],
  [ [0,0], [1,0], [1,1], [2,1] ],
  [ [1,0], [1,1], [0,1], [2,0] ],
  [ [2,0], [2,1], [2,2], [1,1], [0,1] ],
  [ [0,0], [0,1], [0,2], [1,1], [2,1] ],
  [ [0,0], [0,1], [0,2], [1,2], [2,2] ],
  [ [0,0], [1,0], [2,0], [0,1], [1,1] ],
  [ [0,0], [2,0], [1,0], [0,1], [0,2] ],
  [ [0,0], [1,0], [1,1], [1,2], [0,2] ],
  [ [0,1], [1,0], [1,1], [1,2], [2,1] ],
  [ [0,0], [0,1], [0,2], [1,2], [2,1] ], # conway glider
]

CONWAY_MODE_TICKS = 5

FLASH_FADE = 60

BLOCK_BIRTHDAY_FADE = 15

MAX_SCORE_DEFAULT = 350.0
LEVEL_UP_FACTOR = 1.15

UNDO_BUTTON = {
  x: GRID_RECT.x + GRID_RECT.w + CELL_SIZE / 2,
  y: GRID_RECT.y + GRID_RECT.h - CELL_SIZE / 2,
  w: 30,
  h: 30,
  path: 'sprites/undo.png',
}

SHUFFLE_BUTTON = {
  x: DRAWER_X,
  y: DRAWER_Y,
  w: 30,
  h: 30,
  path: 'sprites/shuffle.png',
}

FLASH_MESSAGE_FADE = 45

FLASH_X = GRID_RECT.x + GRID_RECT.w + 25
FLASH_Y = GRID_RECT.y - CELL_SIZE / 2


MENU_BUTTON = {
  x: 1280 - 150 - 15,
  y: 720 - 50 - 15,
  w: 150,
  h: 50,
  size_enum: 10,
  gap: 15
}

BUILD_STR = {
  x: 1200,
  y: 15,
  w: 100,
  r: 150,
  g: 150,
  b: 150,
  size_enum: -4
}

JOURNEY_DRAWER_START = 1

JOURNEY_GOLD = {
  x: 890, y: 555,
  path: 'sprites/coin.png',
  w: 35, h: 35, 
}

GOLD_FG = { r: 173, g: 128, b: 0 }

JOURNEY_GOLD_TXT = {
  x: JOURNEY_GOLD.x + 45, y: 582,
  size_enum: 0,
}.merge(GOLD_FG)

SHOP = 
SHOP_ITEM = { w: 100, h: 50 }

COIN = {
  w: 35, h: 35, 
  path: 'sprites/coin.png',
}

LEVEL = {
  x: 415, y: 600,
  size_enum: -2
}

ITEMS = {
  second_piece: { 
    text: "2nd Piece", cost: 5,
    x: 200, y: 275, w: BLOCK_SIZE, h: BLOCK_SIZE,
    label_dx: 35, label_dy: 85,
  },
  third_piece: {
    text: "3rd Piece", cost: 50,
    x: 200, y: 455, w: BLOCK_SIZE, h: BLOCK_SIZE,
    label_dx: 35, label_dy: 85,
  },
  refresh: { 
    text: "Refresh Every Drop", cost: 50,
    x: 200, y: 20, w: CELL_SIZE * 4, h: CELL_SIZE,
    label_dx: 5, label_dy: 45,
  },
  coins_plus_one: { 
    text: "Coins +1", cost: 3,
    x: 900, y: 400, w: CELL_SIZE * 2, h: CELL_SIZE,
    label_dx: 13, label_dy: 45,
  },
  coins_2x: { 
    text: "Coins 2x", cost: 30,
    x: 900, y: 320, w: CELL_SIZE * 2, h: CELL_SIZE,
    label_dx: 13, label_dy: 45,
  },
  coins_3x: { 
    text: "Coins 3x", cost: 40,
    x: 900, y: 320 - 1.5 * CELL_SIZE, w: CELL_SIZE * 2, h: CELL_SIZE,
    label_dx: 13, label_dy: 45,
  },
  coins_for_combos: {
    text: "Extra Coins per Combo", cost: 35,
    x: 900, y: 320 - 3 * CELL_SIZE, w: CELL_SIZE * 4.5, h: CELL_SIZE,
    label_dx: 13, label_dy: 45,
  },
  refresh_all: {
    text: "Refresh All", cost: 1,
    x: 200, y: 625, w: CELL_SIZE * 3, h: CELL_SIZE,
    label_dx: 13, label_dy: 45,
  },
  single: {
    text: "Single", cost: 1,
    x: 1050, y: 400, w: CELL_SIZE * 2, h: CELL_SIZE,
    label_dx: 13, label_dy: 45,
  },
  # combo: { 
  #   text: "Combo", cost: 30,
  #   x: 1100, y: 320, w: CELL_SIZE * 2, h: CELL_SIZE,
  #   label_dx: 13, label_dy: 45,
  # },
}

COST_COHORT = [
  :refresh, 
  :coins_for_combos, 
  :coins_3x,
  :coins_2x,
  :third_piece,
]

COHORT_INCREASE_FACTOR = 1.5

LEVEL_PROGRESS = {
  x: 25,
  y: GRID_RECT.y,
  w: 50,
  h: 20,
  size_enum: -2,
}

GREY = { r: 120, g: 120, b: 120 }

LEVEL_FADE = 60
LEVEL_ANNOUNCE = {
  x: 510,
  y: 700,
  size_enum: 40,
}

MENU_OPTIONS = { 
  puzzle: "Puzzle",
  journey: "Journey",
  zen: "Zen",
  classic: "Classic",
}

MAIN_MENU = {
  x: 440,
  y: 100,
  w: 400,
  h: 100,
  gap: 25,
  size_enum: 25,
  alignment_enum: 1,
}

GRAVITY = 0.5
GOAT_DDX = -0.5
GOAT_MIN_DX = 1
GOAT_HOP = 3
TERMINAL_VELOCITY = 10
CELEBRATION_FADE = 60
CAT_SIZE = 0.75 * CELL_SIZE

# To convert colors: 
# c = { r: 77, g: 29, b: 104}
# c[:r].to_s16 + c[:g].to_s(16) + c[:b].to_s(16)
JOURNEY_PALLETE = [
  { filled:   { r: 125, g: 29, b: 83},
    scorable: { r: 152, g: 56, b: 110 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },  
  { filled:   { r: 144, g: 34, b: 58},
    scorable: { r: 176, g: 65, b: 89 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },
  { filled:   { r: 156, g: 37, b: 37},
    scorable: { r: 190, g: 70, b: 70 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },
  { filled:   { r: 208, g: 87, b: 22},
    scorable: { r: 253, g: 113, b: 38},
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },
  { filled:   { r: 156, g: 72, b: 37},
    scorable: { r: 190, g: 106, b: 70 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },
  
  { filled:   { r: 156, g: 93, b: 37},
    scorable: { r: 190, g: 127, b: 70 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },
  { filled:   { r: 129, g: 73, b: 0},
    scorable: { r: 162, g: 92, b: 0},
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },
  { filled:   { r: 105, g: 145, b: 34},
    scorable: { r: 136, g: 176, b: 65 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },  
  { filled:   { r: 73, g: 137, b: 32},
    scorable: { r: 103, g: 167, b: 62 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },  
  { filled:   { r: 28, g: 118, b: 48},
    scorable: { r: 53, g: 143, b: 73 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },  
  { filled:   { r: 24, g: 103, b: 79},
    scorable: { r: 46, g: 125, b: 101 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },  
  { filled:   { r: 25, g: 81, b: 97},
    scorable: { r: 46, g: 102, b: 118 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },  
  { filled:   { r: 31, g: 62, b: 102},
    scorable: { r: 53, g: 85, b: 125 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },  
  { filled:   { r: 37, g: 42, b: 108},
    scorable: { r: 60, g: 65, b: 132 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },  
  { filled:   { r: 61, g: 32, b: 106},
    scorable: { r: 84, g: 55, b: 129 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },  
  { filled:   { r: 77, g: 29, b: 104},
    scorable: { r: 100, g: 51, b: 127 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },  
  { filled:   { r: 112, g: 27, b: 96},
    scorable: { r: 136, g: 51, b: 120 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },
  { filled:   { r: 110, g: 110, b: 110},
    scorable: { r: 140, g: 140, b: 140 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },    
  { filled:   { r: 70, g: 70, b: 70},
    scorable: { r: 100, g: 100, b: 100 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },    
  { filled:   { r: 30, g: 30, b: 30},
    scorable: { r: 60, g: 60, b: 60 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },
  { filled:   { r: 30, g: 30, b: 30},
    scorable: { r: 60, g: 60, b: 60 },
    empty:    { r: 200, g: 200, b: 200},
    overlap:  { r: 100, g: 100, b: 100},
  },    
]

CONGRATS = {
  x: 1280 / 2,
  y: 720 / 2 + 100,
  text: "CONGRATULATIONS!",
  alignment_enum: 1,
  size_enum: 50,
}

CONGRATS_FADE = 120
CONGRATS_SWITCH = 5