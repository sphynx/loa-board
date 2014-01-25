# LOA rules implementation.

# Useful constants
WHITE = 'w'
BLACK = 'b'
EMPTY = ' '

START_POS_STR =
  [ ".bbbbbb."
  , "w......w"
  , "w......w"
  , "w......w"
  , "w......w"
  , "w......w"
  , "w......w"
  , ".bbbbbb."
  ];

# Functions
parsePosition = (rows) ->
  convCell = (c) -> if c is "." then EMPTY else c.toLowerCase()

  tboard =
    for row in rows
      for c in row.split("")
        convCell c

  # `zip` here transposes the board, `apply` is needed to pass
  # array elements as separate arguments
  _.zip.apply(null, tboard)

startPosition =
  parsePosition START_POS_STR

verticalAction = (x0, _y0, board) ->
  _.reduce(
    board[x0],
    (acc, c) -> if c is EMPTY then acc else acc + 1,
    0)

horizontalAction = (_x0, y0, board) ->
  _.reduce(
      board,
      (acc, col) -> if col[y0] is EMPTY then acc else acc + 1,
      0)

nwDiagonalAction = (x0, y0, board) ->
  action = 0
  columns = board.length
  rows = board[x0].length

  i = x0
  j = y0
  while i < columns and j >= 0
    if board[i++][j--] isnt EMPTY then action++

  i = x0
  j = y0
  while i > 0 and j < rows-1
    if board[--i][++j] isnt EMPTY then action++

  action

neDiagonalAction = (x0, y0, board) ->
  action = 0
  columns = board.length
  rows = board[x0].length

  i = x0
  j = y0
  while i < columns and j < rows
    if board[i++][j++] isnt EMPTY then action++

  i = x0
  j = y0
  while i > 0 and j > 0
    if board[--i][--j] isnt EMPTY then action++

  action

checkMove = (x0, y0, dx, dy, action, color, board) ->
  oppo = otherColor(color)
  cols = board.length
  rows = board[x0].length

  [i, j, as] = [x0, y0, action]

  loop
    i += dx
    j += dy
    break unless 0 <= i < cols and 0 <= j < rows and as > 1
    if board[i][j] is oppo then return null
    as--

  # Check last cell, it can be either empty or opponent's one
  if 0 <= i < cols and 0 <= j < rows
  then (if board[i][j] is EMPTY or board[i][j] is oppo then [i,j] else null)
  else null

possibleMoves = (x0, y0, board) ->
  checker = board[x0][y0]

  if checker is EMPTY then return []

  moves = []

  vertical = verticalAction(x0, y0, board)
  horizontal = horizontalAction(x0, y0, board)
  nwDiagonal = nwDiagonalAction(x0, y0, board)
  neDiagonal = neDiagonalAction(x0, y0, board)

  check = (dx, dy, as) ->
    checkMove(x0, y0, dx, dy, as, checker, board)

  n = check(0, 1, vertical)
  moves.push(n) if n?

  s = check(0, -1, vertical)
  moves.push(s) if s?

  w = check(-1, 0, horizontal)
  moves.push(w) if w?

  e = check(1, 0, horizontal)
  moves.push(e) if e?

  ne = check(1, 1, neDiagonal)
  moves.push(ne) if ne?

  sw = check(-1, -1, neDiagonal)
  moves.push(sw) if sw?

  nw = check(-1, 1, nwDiagonal)
  moves.push(nw) if nw?

  se = check(1, -1, nwDiagonal)
  moves.push(se) if se?

  moves

otherColor = (color) -> switch color
  when WHITE then BLACK
  when BLACK then WHITE
  else EMPTY

# Public API
global = this
global.LOA =
  possibleMoves : possibleMoves
  startPosition : startPosition
  parsePosition : parsePosition

  # exported only for tests
  # TODO: figure out how to do this properly
  verticalAction : verticalAction
  horizontalAction : horizontalAction
  nwDiagonalAction : nwDiagonalAction
  neDiagonalAction : neDiagonalAction
