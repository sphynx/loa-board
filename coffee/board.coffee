# Constants
CELL_SIZE = 50
ROWS = 8
COLS = 8
RADIUS = CELL_SIZE/2 - 5
BOARD_SIZE = ROWS * CELL_SIZE

LOABoard = () ->
  # INTERNAL STATE
  raphael = null
  model = null

  # KnockiIn.js model
  class LOABoardModel
    constructor: ->
      @black = ko.observableArray([])
      @white = ko.observableArray([])
      @whiteMove = ko.observable(true)
      @selected = null

      @currentMove = ko.computed =>
        if @whiteMove() then "white" else "red"


  # PRIVATE FUNCTIONS

  # ROWS x ROWS grid with path lines
  drawBoard = ->
    path = ""
    for i in [1..9]
      path += "M" + (CELL_SIZE * i) + " " + CELL_SIZE + "v" + BOARD_SIZE
      path += "M" + CELL_SIZE + " "  + CELL_SIZE * i + "h" + BOARD_SIZE
    path += "z"
    raphael.path(path).attr("stroke-width", 1)

  mkChecker = (x, y, color) ->
    checker = raphael.circle(x, y, RADIUS)
    checker.attr("stroke-width", 3)
    checker.attr("fill", color)
    checker.attr("cursor", "crosshair")
    checker.team = color
    checker.node.onclick = -> selectChecker(checker)
    checker

  setPieces = ->
    for i in [2..ROWS-1]
      x = CELL_SIZE * i + CELL_SIZE / 2;

      y = 3/2 * CELL_SIZE;
      model.black.push(mkChecker(x, y, "red"));
      model.white.push(mkChecker(y, x, "white"));

      y = (ROWS + 1/2) * CELL_SIZE;
      model.black.push(mkChecker(x, y, "red"));
      model.white.push(mkChecker(y, x, "white"));

  selectChecker = (checker) ->
    if model.selected? then model.selected.attr("fill", model.selected.team)
    checker.attr("fill", "yellow")
    model.selected = checker
    x0 = (checker.attr("cx") - 75) / 50
    y0 = 7 - (checker.attr("cy") - 75) / 50

    # just log it for now
    console.log(x0, y0)
    console.log(LOA.possibleMoves(x0, y0, LOA.startPosition))

  # PUBLIC FUNCTIONS

  # Entry point
  init = ->
    raphael = Raphael("holder", 500, 500)
    model = new LOABoardModel()
    ko.applyBindings(model)
    drawBoard()
    setPieces()

  # Public API
  init : init

# Ininitialization from JQuery
$ -> LOABoard().init()








