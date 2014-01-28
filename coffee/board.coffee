# Constants
ROWS = 9
COLS = 9
CELL_SIZE = 50
RADIUS = CELL_SIZE/2 - 5

LOABoard = () ->
  # INTERNAL STATE
  raphael = null
  model = null

  board = LOA.startPosition(ROWS, COLS)

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
        if @whiteMove() then "white" else "red"

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
      raphael.path("M" + CELL_SIZE * i + " " + CELL_SIZE + "v" + ROWS * CELL_SIZE)

    for i in [1 .. ROWS+1]
      raphael.path("M" + CELL_SIZE + " "  + CELL_SIZE * i + "h" + COLS * CELL_SIZE)

  drawPosition = (pos) ->
    for i in [0 .. COLS-1]
      for j in [0 .. ROWS-1]
        switch pos[i][j]
          when LOA.BLACK
            drawChecker(i, j, "red")
            model.black(model.black() + 1)
          when LOA.WHITE
            drawChecker(i, j, "white")
            model.white(model.white() + 1)

  offSelection = ->
    old.remove() for old in moveCells

  drawPossibleMoves = (moves, pos, from) ->
    offSelection()
    for move in moves
      [i,j] = move
      moveCells.push(highlightSquare(i, j, from))

  highlightSquare = (i0, j0, from) ->
    [x,y] = indexToCoord(i0, j0)
    delta = 2
    back = raphael.rect(
      x - CELL_SIZE/2 + 1
      y - CELL_SIZE/2 + 1
      CELL_SIZE-delta
      CELL_SIZE-delta
      )

    back.attr
      fill: "white"
      "fill-opacity": 0.1
      cursor: "crosshair"

    back.node.onclick = () ->
      whiteCaptured = board[i0][j0] is LOA.WHITE
      blackCaptured = board[i0][j0] is LOA.BLACK
      isCapture = whiteCaptured or blackCaptured

      # update board array
      [from_x0, from_y0] = coordToIndex(from.attr("cx"), from.attr("cy"))
      board[i0][j0] = board[from_x0][from_y0]
      board[from_x0][from_y0] = LOA.EMPTY

      # update visual representation
      offSelection()
      if isCapture
        raphael.getElementsByPoint(x, y).remove()
        if blackCaptured
          model.black(model.black() - 1)
        else
          model.white(model.white() - 1)
      from.animate({ cx: x, cy: y }, 100)
      from.animate({"r": 20}, 1000, "elastic")

      model.changeMove()

    back

  drawChecker = (i0, j0, color) ->
    [x, y] = indexToCoord(i0, j0)
    checker = raphael.circle(x, y, RADIUS)
    checker.attr
      "stroke-width": 3
      fill: color
      cursor: "crosshair"
    checker.origColor = color
    checker.node.onclick = -> selectChecker(checker)
    checker

  selectChecker = (checker) ->
    if checker.origColor isnt model.currentMove() then return
    checker.animate({"r": 23}, 1000, "elastic")
    selectedChecker.animate({"r": 20}, 1000, "elastic") if selectedChecker?
    selectedChecker = checker
    [x0, y0] = coordToIndex(checker.attr("cx"), checker.attr("cy"))
    moves = LOA.possibleMoves(x0, y0, board)
    drawPossibleMoves(moves, board, checker)

  # PUBLIC FUNCTIONS

  # Entry point
  init : ->
    raphael = Raphael("holder", 500, 500)
    model = new LOABoardModel()
    ko.applyBindings(model)
    drawBoard()
    drawPosition(board)

# Initialization from JQuery
$ -> LOABoard().init()
