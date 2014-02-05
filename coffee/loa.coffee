# LOA rules implementation.

# Useful constants
WHITE = 'w'
BLACK = 'b'
EMPTY = ' '

replicate = (n, str) ->
  _(n).times(-> str)

genNormalStartPos = (rows, cols) ->
  black_row = EMPTY + replicate(cols-2, BLACK).join("") + EMPTY
  white_row = WHITE + replicate(cols-2, EMPTY).join("") + WHITE
  arr = replicate(rows-2, white_row)
  arr.unshift(black_row)
  arr.push(black_row)
  arr

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

startPosition = (rows, cols) ->
  parsePosition(genNormalStartPos(rows, cols))

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
    if board[i][j] is oppo then return []
    as--

  # Check the last cell, it should not have our own checker
  if 0 <= i < cols and 0 <= j < rows and board[i][j] isnt color
    [ from: {i: x0, j: y0}, to: {i: i, j: j}, isCapture: board[i][j] isnt EMPTY ]
  else
    [] # no moves

possibleMoves = (x0, y0, board) ->
  checker = board[x0][y0]

  if checker is EMPTY then return []

  vertical = verticalAction(x0, y0, board)
  horizontal = horizontalAction(x0, y0, board)
  nwDiagonal = nwDiagonalAction(x0, y0, board)
  neDiagonal = neDiagonalAction(x0, y0, board)

  check = (dx, dy, as) ->
    checkMove(x0, y0, dx, dy, as, checker, board)

  moves = []
  moves.push(check( 0,  1, vertical))
  moves.push(check( 0, -1, vertical))
  moves.push(check(-1,  0, horizontal))
  moves.push(check( 1,  0, horizontal))
  moves.push(check( 1,  1, neDiagonal))
  moves.push(check(-1, -1, neDiagonal))
  moves.push(check(-1,  1, nwDiagonal))
  moves.push(check( 1, -1, nwDiagonal))
  _.flatten(moves)

otherColor = (color) -> switch color
  when WHITE then BLACK
  when BLACK then WHITE
  else EMPTY

# Public API
global = this
global.LOA =
  WHITE : WHITE
  BLACK : BLACK
  EMPTY : EMPTY
  possibleMoves : possibleMoves
  startPosition : startPosition
  parsePosition : parsePosition

  # exported only for tests
  # TODO: figure out how to do this properly
  verticalAction : verticalAction
  horizontalAction : horizontalAction
  nwDiagonalAction : nwDiagonalAction
  neDiagonalAction : neDiagonalAction
