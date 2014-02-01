###
LOA API we want to test:

function parsePosition(rows)
function possibleMoves(x1, y1, board)
function checkMove(x0, y0, dx, dy, action, color, board)
function otherColor(color)
function verticalAction(x0, y0, board)
function horizontalAction(x0, y0, board)
function nwDiagonalAction(x0, y0, board)
function neDiagonalAction(x0, y0, board)
###

# Helpers

m = (fromx, fromy, tox, toy) ->
  from: {i: fromx, j: fromy}
  to: {i: tox, j: toy}

emptyPosStr =
  [ "........"
  , "........"
  , "........"
  , "........"
  , "........"
  , "........"
  , "........"
  ];

termPosStr =
  [ "........"
  , "ww......"
  , ".....w.."
  , ".w.b...."
  , "..wb.b.."
  , ".bb.b..."
  , ".....b.."
  , "....w..."
  ];

termPos = LOA.parsePosition(termPosStr)

s0Expected =
  [[" ", "w", "w", "w", "w", "w", "w", " "]
  ,["b", " ", " ", " ", " ", " ", " ", "b"]
  ,["b", " ", " ", " ", " ", " ", " ", "b"]
  ,["b", " ", " ", " ", " ", " ", " ", "b"]
  ,["b", " ", " ", " ", " ", " ", " ", "b"]
  ,["b", " ", " ", " ", " ", " ", " ", "b"]
  ,["b", " ", " ", " ", " ", " ", " ", "b"]
  ,[" ", "w", "w", "w", "w", "w", "w", " "]
  ]

s0 = LOA.startPosition(8,8)

vert = (board, x0, expected) ->
  equal(LOA.verticalAction(x0, 0, board), expected,
    "Vertical for start position in row {0}".format(x0))

horiz = (board, y0, expected) ->
  equal(LOA.horizontalAction(0, y0, board), expected,
    "Horizontal for start position in column {0}".format(y0))


nw = (board, x0, y0, expected) ->
  equal(LOA.nwDiagonalAction(x0, y0, board), expected,
    "NW diagonal for start position in x0={0}, y0={1}".format(x0, y0))


ne = (board, x0, y0, expected) ->
  equal(LOA.neDiagonalAction(x0, y0, board), expected,
    "NE diagonal for start position in x0={0}, y0={1}".format(x0, y0))


moves = (board, x1, y1, expected) ->
  sortf = (move) -> [move.to.i, move.to.j]
  deepEqual(
    _.sortBy(LOA.possibleMoves(x1, y1, board), sortf),
    _.sortBy(expected, sortf),
    "Moves in start position for x1={0} and y1={1}".format(x1, y1))


# TESTS

test("Position parsing", ->
  deepEqual(s0, s0Expected, "start position");
)

test("Vertical actions in start position", ->
  vert(s0, 0, 6)
  vert(s0, i, 2) for i in [1..6]
  vert(s0, 7, 6)
)

test("Horizontal actions in start position", ->
    horiz(s0, 0, 6)
    horiz(s0, i, 2) for i in [1..6]
    horiz(s0, 7, 6)
)

test("NW diagonal actions in start position", ->
  for i in [0..7]
    for j in [0..7]
      expected =
        if i is 7-j or (i is 0 and j is 0) or (i is 7 and j is 7)
          0
        else
          2
      nw(s0, i, j, expected)
)

test("NE diagonal actions in start position", ->
  for i in [0..7]
    for j in [0..7]
      expected =
        if i is j or (i is 0 and j is 7) or (i is 7 and j is 0)
          0
        else
          2
      ne(s0, i, j, expected)
)

test("Possible moves", ->
    # no moves from empty cells
    moves(s0, i, i, []) for i in [0..7]
    moves(s0, 1, 2, [])
    moves(s0, 2, 4, [])
    moves(s0, 6, 3, [])

    # normal moves
    moves(s0, 0, 1, [m(0,1,0,7), m(0,1,2,1), m(0,1,2,3)])
    moves(s0, 1, 0, [m(1,0,1,2), m(1,0,3,2), m(1,0,7,0)])
    moves(s0, 5, 0, [m(5,0,3,2), m(5,0,5,2), m(5,0,7,2)])
    moves(s0, 0, 6, [m(0,6,0,0), m(0,6,2,4), m(0,6,2,6)])
    moves(s0, 7, 3, [m(7,3,5,1), m(7,3,5,3), m(7,3,5,5)])
)

