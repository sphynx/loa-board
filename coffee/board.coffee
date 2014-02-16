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
BLACK_PLAYER = "Black"
WHITE_PLAYER = "White"

# Move drawing modes
LOAD = "load"  # when loading moves
REDRAW = "redraw" # when redrawing (when we want to go to certain position)
VARIATION = "variation" # actually entering new moves/variations with mouse

LOABoard = () ->
  # INTERNAL STATE
  raphael = null
  model = null

  # board: internal array
  board = LOA.startPosition(ROWS, COLS)
  # mapping between indices and SVG checker elements
  checkers = []

  # Global SVG elements
  selectedChecker = null
  moveCells = []

  # KnockIn.js model
  class LOABoardModel
    constructor: () ->
      @whiteCheckers = ko.observable(0)
      @blackCheckers = ko.observable(0)
      @whiteMove = ko.observable(false)

      @tagEvent = ko.observable("")
      @tagWhite = ko.observable("")
      @tagBlack = ko.observable("")
      @tagResult = ko.observable("")

      @actualMoves = ko.observableArray()
      @variationMoves = ko.observableArray()
      @lastMove = ko.observable(0)
      @variationStart = ko.observable(0)

      @mainlineClick = (move) =>
        n = move.number
        @lastMove(n)
        @variationStart(n)
        @variationMoves([])
        displayPositionAfterMoves(@actualMoves[0..n-1])

      @variationClick = (move) =>
        n = move.number
        @lastMove(n)
        take = n - @variationStart()
        @variationMoves(@variationMoves[0..take-1])
        displayPositionAfterMoves(@actualMoves().concat(@variationMoves()))

      @currentMove = ko.computed =>
        if @whiteMove()
          WHITE_PLAYER
        else
          BLACK_PLAYER

      @changeMove = () -> @whiteMove(not @whiteMove())

      @initTags = (tags) =>
        @tagEvent(tags[PGN.EVENT])
        @tagWhite(tags[PGN.WHITE])
        @tagBlack(tags[PGN.BLACK])
        @tagResult(tags[PGN.RESULT])

      @reset = () =>
        @whiteCheckers(0)
        @blackCheckers(0)
        @whiteMove(false)

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

  drawBoard = ->
    for i in [1 .. COLS]
      for j in [1 .. ROWS]
        field = raphael.rect(CELL_SIZE * i, CELL_SIZE * j, CELL_SIZE, CELL_SIZE, 0)
        field.attr
          "fill": if (i+j) % 2 is 0 then "rgb(255, 215, 164)" else "rgb(211, 145, 61)"
          "stroke-width": 1

  drawCoordinates = ->
    alphabet = "abcdefghijklmnopqrstuvwxyz"
    for i in [0 .. COLS-1]
      raphael.text(CELL_SIZE * (i + 1.5), CELL_SIZE * (COLS + 1.5), alphabet[i])
    for j in [1 .. ROWS]
      raphael.text(CELL_SIZE * 0.5, CELL_SIZE * (9.5 - j), j)

  drawPosition = (pos) ->
    for i in [0 .. COLS-1]
      checkers[i] = []
      for j in [0 .. ROWS-1]
        switch pos[i][j]
          when LOA.BLACK
            checkers[i][j] = drawChecker(i, j, BLACK_PLAYER, BLACK_CHECKER_COLOR)
            model.blackCheckers(model.blackCheckers() + 1)
          when LOA.WHITE
            checkers[i][j] = drawChecker(i, j, WHITE_PLAYER, WHITE_CHECKER_COLOR)
            model.whiteCheckers(model.whiteCheckers() + 1)

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
      animateSelect(checker)
      selectedChecker = checker
      [x0, y0] = coordToIndex(checker.attr("cx"), checker.attr("cy"))
      drawPossibleMoves(LOA.possibleMoves(x0, y0, board))
    checker

  animateSelect = (checker) ->
    checker.animate({ r: RADIUS + 2}, 1000, "elastic")
    selectedChecker.animate({ r: RADIUS}, 1000, "elastic") if selectedChecker?

  visualizeMove = (checker, x, y, mode) ->
    if mode is VARIATION
      checker.animate({ cx: x, cy: y }, 100)
      checker.animate({ r: RADIUS}, 1000, "elastic")
    else
      checker.attr
        cx: x
        cy: y

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

    back.node.onclick = () -> doMove(move, VARIATION)
    back

  resetPossibleMoves = ->
    old.remove() for old in moveCells

  doMove = (move, mode) ->
    whiteCaptured = board[move.to.i][move.to.j] is LOA.WHITE
    blackCaptured = board[move.to.i][move.to.j] is LOA.BLACK
    isCapture = move.isCapture

    # update model and board array
    board[move.to.i][move.to.j] = board[move.from.i][move.from.j]
    board[move.from.i][move.from.j] = LOA.EMPTY

    if blackCaptured
        model.blackCheckers(model.blackCheckers() - 1)
    else if whiteCaptured
        model.whiteCheckers(model.whiteCheckers() - 1)

    switch mode
      when LOAD
        model.lastMove(model.lastMove() + 1)
        model.variationStart(model.variationStart() + 1)
        move.number = model.lastMove()
        move.moveText = PGN.printMove(move)
        model.actualMoves.push(move)
      when VARIATION
        model.lastMove(model.lastMove() + 1)
        move.number = model.lastMove()
        move.moveText = PGN.printMove(move)
        model.variationMoves.push(move)

    model.changeMove()

    # update visual representation
    resetPossibleMoves()

    if isCapture then checkers[move.to.i][move.to.j].remove()

    movingChecker = checkers[move.from.i][move.from.j]
    [toX, toY] = indexToCoord(move.to.i, move.to.j)
    visualizeMove(movingChecker, toX, toY, mode)

    checkers[move.to.i][move.to.j] = movingChecker
    checkers[move.from.i][move.from.j] = null

  removeCheckers = () ->
    for i in [0..COLS-1]
      for j in [0..ROWS-1]
        checkers[i][j].remove() if checkers[i][j]?

  displayPositionAfterMoves = (moves) ->
    board = LOA.startPosition(ROWS, COLS)
    model.reset()
    removeCheckers()
    drawPosition(board)
    doMove(m, REDRAW) for m in moves

  # PUBLIC FUNCTIONS

  # Entry point
  init: ->
    raphael = Raphael("holder", 500, 500)
    model = new LOABoardModel()
    drawBoard()
    drawCoordinates()
    drawPosition(board)
    if not not window.GAME # check if it's not empty JS-way ;)
      game = PGN.parseGame(window.GAME)
      model.initTags(game.tags)
      document.title =
        "LOA game: " + game.tags[PGN.WHITE] + " - " + game.tags[PGN.BLACK]
      doMove(m, LOAD) for m in game.moves
    ko.applyBindings(model)

# initialization from JQuery
$ -> LOABoard().init()
