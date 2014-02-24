# Constants

# Visual
CELL_SIZE = 50
RADIUS = CELL_SIZE/2 - 6
BLACK_CHECKER_COLOR = "red"
WHITE_CHECKER_COLOR = "white"
CHECKER_STROKE_WIDTH = 2
CHECKER_CURSOR = "pointer"

LIGHT_SQUARE = "rgb(255, 215, 164)"
DARK_SQUARE = "rgb(211, 145, 61)"

# Game-related
BLACK_PLAYER = "Black"
WHITE_PLAYER = "White"

# Move drawing modes
LOAD = "load"  # when loading moves from the server
REDRAW = "redraw" # when redrawing (when we want to go to certain position)
VARIATION = "variation" # actually entering new moves/variations with mouse

LOABoard = (variant) ->
  # INTERNAL STATE
  raphael = null
  model = null
  variant = variant

  rows = if variant is LOA.VARIANT_BLACKHOLE then 9 else 8
  cols = if variant is LOA.VARIANT_BLACKHOLE then 9 else 8

  # internal board array
  board = LOA.startPosition(variant)
  # mapping between indices and SVG checker elements
  checkers = []

  # Global SVG elements
  selectedChecker = null
  moveCells = []
  lastMoveSVG = []

  # KnockIn.js model
  class LOABoardModel
    constructor: () ->
      @whiteCheckers = ko.observable(0)
      @blackCheckers = ko.observable(0)
      @whiteMove = ko.observable(false)

      @tagEvent = ko.observable("none")
      @tagWhite = ko.observable("unknown")
      @tagBlack = ko.observable("unknown")
      @tagResult = ko.observable("*")

      @actualMoves = ko.observableArray()
      @variationMoves = ko.observableArray()
      @lastMove = ko.observable(0)
      @variationStart = ko.observable(0)

      @isCurrentMove = (index) =>
        if @inMainline()
          index() + 1 is @lastMove()
        else
          index() + 2 is @variationStart()

      @mainlineClick = (move) =>
        n = move.number
        @lastMove(n)
        @variationStart(0)
        @variationMoves([])
        @displayMoves()

      @variationClick = (move) =>
        n = move.number
        @lastMove(n)
        @variationMoves(@variationMoves[0 .. n - @variationStart()])
        actualMovesPart = @actualMoves[0 .. @variationStart() - 2]
        displayPositionAfterMoves(actualMovesPart.concat(@variationMoves()))

      @gotoPrevMove = () =>
        if @inMainline()
          if @lastMove() > 1
            @lastMove(@lastMove() - 1)
            @displayMoves()
        else
          @lastMove(@lastMove() - 1)
          actualMovesPart = []
          if @lastMove() < @variationStart()
            @variationStart(0)
            @variationMoves([])
            actualMovesPart = @actualMoves[0 .. @lastMove()]
          else
            @variationMoves(@variationMoves[0 .. @lastMove() - @variationStart() ])
            actualMovesPart = @actualMoves[0 .. @variationStart() - 2]
          displayPositionAfterMoves(actualMovesPart.concat(@variationMoves()))

      @gotoNextMove = () =>
        if @lastMove() < @actualMoves().length and @inMainline()
          @lastMove(@lastMove() + 1)
          @displayMoves()

      @gotoStart = () =>
        if @inMainline()
          @lastMove(1)
          @displayMoves()

      @gotoEnd = () =>
        if @inMainline()
          @lastMove(@actualMoves().length)
          @displayMoves()

      @inVariation = ko.computed =>
        @variationMoves().length > 0

      @inMainline = ko.computed =>
        not @inVariation()

      @displayMoves = () =>
        displayPositionAfterMoves(@actualMoves[0..@lastMove() - 1])

      @currentMove = ko.computed =>
        if @whiteMove()
          WHITE_PLAYER
        else
          BLACK_PLAYER

      @changeMove = () ->
        @whiteMove(not @whiteMove())

      @initTags = (tags) =>
        @tagEvent(tags[PGN.EVENT])

        # Black/white exchanged to overcome LG bug, white player is
        # listed as black in their PGN!
        @tagWhite(tags[PGN.BLACK])
        @tagBlack(tags[PGN.WHITE])
        @tagResult(PGN.printResult(tags[PGN.RESULT]))

      @reset = () =>
        @whiteCheckers(0)
        @blackCheckers(0)
        @whiteMove(false)

  # PRIVATE FUNCTIONS

  # conversion functions. It's probably better to do it using SVG transform
  # but it looks more complicated now
  indexToCoord = (i0, j0) ->
    [ CELL_SIZE * (i0 + 1.5)
    , CELL_SIZE * (rows - j0 + 0.5)
    ]

  coordToIndex = (x, y) ->
    [ x / CELL_SIZE - 1.5
    , rows + 0.5 - y / CELL_SIZE
    ]

  drawBoard = () ->
    for i in [1 .. cols]
      for j in [1 .. rows]
        field = raphael.rect(CELL_SIZE * i, CELL_SIZE * j, CELL_SIZE, CELL_SIZE, 0)
        field.attr
          "fill": if (i+j) % 2 is 0 then LIGHT_SQUARE else DARK_SQUARE

  drawCoordinates = () ->
    alphabet = "abcdefghijklmnopqrstuvwxyz"
    for i in [0 .. cols-1]
      raphael.text(CELL_SIZE * (i + 1.5), CELL_SIZE * (cols + 1.5), alphabet[i])
    for j in [1 .. rows]
      raphael.text(CELL_SIZE * 0.5, CELL_SIZE * (cols - j + 1.5), j)

  drawPosition = (pos) ->
    for i in [0 .. cols-1]
      checkers[i] = []
      for j in [0 .. rows-1]
        switch pos[i][j]
          when LOA.BLACK
            checkers[i][j] = drawChecker(i, j, BLACK_PLAYER, BLACK_CHECKER_COLOR)
            model.blackCheckers(model.blackCheckers() + 1)
          when LOA.WHITE
            checkers[i][j] = drawChecker(i, j, WHITE_PLAYER, WHITE_CHECKER_COLOR)
            model.whiteCheckers(model.whiteCheckers() + 1)
          when LOA.HOLE
            checkers[i][j] = drawBlackHole(i, j)

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

  drawBlackHole = (i0, j0) ->
    [x, y] = indexToCoord(i0, j0)
    hole = raphael.rect(x - CELL_SIZE/2, y - CELL_SIZE/2, CELL_SIZE, CELL_SIZE, 0)
    hole.attr
      "fill": "black"
      "fill-opacity": 0.6
    hole

  animateSelect = (checker) ->
    checker.animate({ r: RADIUS + 2 }, 1000, "elastic")
    selectedChecker.animate({ r: RADIUS }, 1000, "elastic") if selectedChecker?

  visualizeMove = (checker, x, y, mode, intoBlackHole) ->
    if mode is VARIATION
      checker.animate({ cx: x, cy: y }, 100)
      if intoBlackHole
        checker.animate({ r: RADIUS }, 500, "elastic", () -> checker.remove())
      else
        checker.animate({ r: RADIUS }, 1000, "elastic")
    else
      if intoBlackHole
        checker.remove()
      else
        checker.attr
          cx: x
          cy: y

  drawLastMove = (move) ->
    resetLastMove()
    [fromX, fromY] = indexToCoord(move.from.i, move.from.j)
    [toX, toY] = indexToCoord(move.to.i, move.to.j)
    lastMoveSVG.push(drawLast(fromX, fromY))
    lastMoveSVG.push(drawLast(toX, toY))

  drawLast = (x, y) ->
    delta = 2
    back = raphael.rect(
      x - CELL_SIZE/2 + 1
      y - CELL_SIZE/2 + 1
      CELL_SIZE - delta
      CELL_SIZE - delta
      )
    back.attr
      "fill": "yellow"
      "fill-opacity": 0.3
    back

  resetLastMove = () ->
    old.remove() for old in lastMoveSVG

  drawPossibleMoves = (moves) ->
    resetPossibleMoves()
    resetLastMove()
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
    if move is PGN.RESIGN then return

    whiteCaptured = board[move.to.i][move.to.j] is LOA.WHITE
    blackCaptured = board[move.to.i][move.to.j] is LOA.BLACK
    intoBlackHole = board[move.to.i][move.to.j] is LOA.HOLE
    isCapture = move.isCapture

    # update model and board array
    if not intoBlackHole
      board[move.to.i][move.to.j] = board[move.from.i][move.from.j]
    board[move.from.i][move.from.j] = LOA.EMPTY

    # update checker counters
    if blackCaptured
      model.blackCheckers(model.blackCheckers() - 1)
    else if whiteCaptured
      model.whiteCheckers(model.whiteCheckers() - 1)
    else if intoBlackHole
      if model.whiteMove()
        model.whiteCheckers(model.whiteCheckers() - 1)
      else
        model.blackCheckers(model.blackCheckers() - 1)

    switch mode
      when LOAD
        model.lastMove(model.lastMove() + 1)
        move.number = model.lastMove()
        move.moveText = PGN.printMove(move)
        model.actualMoves.push(move)
      when VARIATION
        model.lastMove(model.lastMove() + 1)
        if model.variationStart() is 0
          model.variationStart(model.lastMove())
        move.number = model.lastMove()
        move.moveText = PGN.printMove(move)
        model.variationMoves.push(move)

    model.changeMove()

    # update visual representation
    resetPossibleMoves()

    if isCapture then checkers[move.to.i][move.to.j].remove()

    movingChecker = checkers[move.from.i][move.from.j]
    [toX, toY] = indexToCoord(move.to.i, move.to.j)
    visualizeMove(movingChecker, toX, toY, mode, intoBlackHole)
    drawLastMove(move)

    if not intoBlackHole
      checkers[move.to.i][move.to.j] = movingChecker
    checkers[move.from.i][move.from.j] = null

  removeCheckers = () ->
    for i in [0..cols-1]
      for j in [0..rows-1]
        checkers[i][j].remove() if checkers[i][j]?

  displayPositionAfterMoves = (moves) ->
    board = LOA.startPosition(variant)
    model.reset()
    removeCheckers()
    drawPosition(board)
    doMove(m, REDRAW) for m in moves

  initKeyboard = () ->
    Mousetrap.bind('left', () -> model.gotoPrevMove())
    Mousetrap.bind('right', () -> model.gotoNextMove())
    Mousetrap.bind('down', () -> model.gotoStart(); false)
    Mousetrap.bind('up', () -> model.gotoEnd(); false)

  # PUBLIC FUNCTIONS

  # Entry point
  init: ->
    raphael = Raphael("holder", 550, 550)
    model = new LOABoardModel()
    drawBoard()
    drawCoordinates()
    drawPosition(board)
    initKeyboard()
    if not not window.GAME # check if it's not empty JS-way ;)
      game = PGN.parseGame(window.GAME)
      model.initTags(game.tags)
      document.title =
        "LOA game: " + game.tags[PGN.WHITE] + " - " + game.tags[PGN.BLACK]
      doMove(m, LOAD) for m in game.moves
    else
      $("#lg_link").html("none")

    ko.applyBindings(model)

# initialization from JQuery
$ -> LOABoard(window.VARIANT).init()
