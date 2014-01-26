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
      # Old stuff, most likely it will be rewritten somehow.
      @black = ko.observableArray([])
      @white = ko.observableArray([])
      @whiteMove = ko.observable(true)
      @currentMove = ko.computed =>
        if @whiteMove() then "white" else "red"

  # PRIVATE FUNCTIONS

  # ROWS x COLS grid with path lines
  drawBoard = ->
    path = ""
    for i in [1 .. COLS+1]
      path += "M" + CELL_SIZE * i + " " + CELL_SIZE + "v" + ROWS * CELL_SIZE

    for i in [1 .. ROWS+1]
      path += "M" + CELL_SIZE + " "  + CELL_SIZE * i + "h" + COLS * CELL_SIZE
    path += "z"

    raphael.path(path).attr("stroke-width", 1)

  drawPosition = (pos) ->
    for i in [0 .. COLS-1]
      for j in [0 .. ROWS-1]
        switch pos[i][j]
          when LOA.BLACK
            model.black.push(mkChecker(i, j, "red"))
          when LOA.WHITE
            model.white.push(mkChecker(i, j, "white"))

  drawPossibleMoves = (moves, pos) ->
    old.remove() for old in moveCells
    for move in moves
      [i,j] = move
      moveCells.push(highlightSquare(i, j))

  highlightSquare = (x0, y0) ->
    [x,y] = indexToCoord(x0, y0)
    delta = 2
    back = raphael.rect(
      x - CELL_SIZE/2 + 1
      y - CELL_SIZE/2 + 1
      CELL_SIZE-delta
      CELL_SIZE-delta
      )
    back.toBack()
    back.attr
      fill: "blue"
    back

  # Conversion functions. It's probably better to do it using SVG transform
  # but it looks more complicated now
  indexToCoord = (i0, j0) ->
    [ CELL_SIZE * (i0 + 1.5)
    , CELL_SIZE * (ROWS - j0 + 0.5)
    ]

  coordToIndex = (x, y) ->
    [ x / CELL_SIZE - 1.5
    , ROWS + 0.5 - y / CELL_SIZE
    ]

  mkChecker = (i0, j0, color) ->
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
    selectedChecker.attr(fill : selectedChecker.origColor) if selectedChecker?
    checker.attr("fill", "yellow")
    [x0, y0] = coordToIndex(checker.attr("cx"), checker.attr("cy"))
    selectedChecker = checker
    moves = LOA.possibleMoves(x0, y0, board)
    drawPossibleMoves(moves, board)

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
