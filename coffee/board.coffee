# Constants

# Visual
ROWS = 8
COLS = 8
CELL_SIZE = 50
RADIUS = CELL_SIZE/2 - 6
BLACK_CHECKER_COLOR = "red"
WHITE_CHECKER_COLOR = "white"
CHECKER_STROKE_WIDTH = 2
CHECKER_CURSOR = "crosshair"

# Game-related
BLACK_PLAYER = "black"
WHITE_PLAYER = "white"

LOABoard = () ->
  # INTERNAL STATE
  raphael = null
  model = null

  # board: internal array and mapping between indices and SVG checker elements
  board = LOA.startPosition(ROWS, COLS)
  checkers = []

  # Global SVG elements
  selectedChecker = null
  moveCells = []

  # KnockIn.js model
  class LOABoardModel
    constructor: () ->
      @white = ko.observable(0)
      @black = ko.observable(0)
      @whiteMove = ko.observable(false)
      @currentMove = ko.computed =>
        if @whiteMove() then WHITE_PLAYER else BLACK_PLAYER

      @changeMove = () -> @whiteMove(not @whiteMove())

  # PRIVATE FUNCTIONS

  # conversion functions. It's probably better to do it using SVG transform
  # but it looks more complicated now
  indexToCoord = (i0, j0) ->
    [ CELL_SIZE * (i0 + 1.5)
    , CELL_SIZE * (ROWS - j0 + 0.5)
    ]

  coordToIndex = (x, y) ->
    [ x / CELL_SIZE - 1.5
    , ROWS + 0.5 - y / CELL_SIZE
    ]

  # ROWS x COLS grid with path lines
  drawBoard = ->
    for i in [1 .. COLS+1]
      p = raphael.path("M" + CELL_SIZE * i + " " + CELL_SIZE + "v" + ROWS * CELL_SIZE)
      p.attr
        stroke: "rgb(168,124,53)"

    for i in [1 .. ROWS+1]
      p = raphael.path("M" + CELL_SIZE + " "  + CELL_SIZE * i + "h" + COLS * CELL_SIZE)
      p.attr
        stroke: "rgb(168,124,53)"

    for i in [1 .. COLS]
      for j in [1 .. ROWS]
        field = raphael.rect(CELL_SIZE * i + 1, CELL_SIZE * j + 1, CELL_SIZE - 2, CELL_SIZE - 2, 0)
        field.attr
          fill: if (i+j) % 2 is 0 then "rgb(255, 215, 164)" else "rgb(211, 145, 61)"

  drawPosition = (pos) ->
    for i in [0 .. COLS-1]
      checkers[i] = []
      for j in [0 .. ROWS-1]
        switch pos[i][j]
          when LOA.BLACK
            checkers[i][j] = drawChecker(i, j, BLACK_PLAYER, BLACK_CHECKER_COLOR)
            model.black(model.black() + 1)
          when LOA.WHITE
            checkers[i][j] = drawChecker(i, j, WHITE_PLAYER, WHITE_CHECKER_COLOR)
            model.white(model.white() + 1)

  drawChecker = (i0, j0, player, color) ->
    [x, y] = indexToCoord(i0, j0)
    checker = raphael.circle(x, y, RADIUS)
    checker.player = player
    checker.attr
      "fill": color
      "stroke-width": CHECKER_STROKE_WIDTH
      "cursor": CHECKER_CURSOR
    checker.node.onclick = () ->
      if checker.player isnt model.currentMove() then return
      checker.animate({"r": RADIUS + 2}, 1000, "elastic")
      selectedChecker.animate({"r": RADIUS}, 1000, "elastic") if selectedChecker?
      selectedChecker = checker
      [x0, y0] = coordToIndex(checker.attr("cx"), checker.attr("cy"))
      drawPossibleMoves(LOA.possibleMoves(x0, y0, board))
    checker

  drawPossibleMoves = (moves) ->
    resetPossibleMoves()
    moveCells.push(drawPossibleMove(move)) for move in moves

  drawPossibleMove = (move) ->
    [x,y] = indexToCoord(move.to.i, move.to.j)
    delta = 2
    back = raphael.rect(
      x - CELL_SIZE/2 + 1
      y - CELL_SIZE/2 + 1
      CELL_SIZE - delta
      CELL_SIZE - delta
      )

    back.attr
      "fill": "green"
      "fill-opacity": 0.3
      "cursor": "crosshair"

    back.node.onclick = () -> doMove(move)
    back

  resetPossibleMoves = ->
    old.remove() for old in moveCells

  doMove = (move) ->
    whiteCaptured = board[move.to.i][move.to.j] is LOA.WHITE
    blackCaptured = board[move.to.i][move.to.j] is LOA.BLACK
    isCapture = move.isCapture

    # update model and board array
    board[move.to.i][move.to.j] = board[move.from.i][move.from.j]
    board[move.from.i][move.from.j] = LOA.EMPTY

    if blackCaptured
        model.black(model.black() - 1)
    else if whiteCaptured
        model.white(model.white() - 1)

    model.changeMove()

    # update visual representation
    resetPossibleMoves()

    if isCapture then checkers[move.to.i][move.to.j].remove()

    movingChecker = checkers[move.from.i][move.from.j]
    [toX, toY] = indexToCoord(move.to.i, move.to.j)
    movingChecker.animate({ cx: toX, cy: toY }, 100)
    movingChecker.animate({"r": RADIUS}, 1000, "elastic")

    checkers[move.to.i][move.to.j] = movingChecker
    checkers[move.from.i][move.from.j] = null

  # PUBLIC FUNCTIONS

  # Entry point
  init : ->
    raphael = Raphael("holder", 500, 500)
    model = new LOABoardModel()
    ko.applyBindings(model)
    drawBoard()
    drawPosition(board)
    if not not window.GAME # check if it's not empty JS-way ;)
      doMove(m) for m in PGN.parseGame(window.GAME)

# initialization from JQuery
$ -> LOABoard().init()
