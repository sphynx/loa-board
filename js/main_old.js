(function() {
     // to make global context more apparent
     var global = this;

     // constants
     var CELL_SIZE = 50, // board cell size
         ROWS = 8, // number of board rows and columns
         RADIUS = CELL_SIZE/2 - 5, // radius of a piece
         BOARD_SIZE = ROWS * CELL_SIZE; // board size

     // constructor, available in global namespace
     global.LOABoard = function() {
         // private instance variable
         var raphael; // Raphael object

         // Knockout.js model object
         var model = {
             white: ko.observableArray([]),
             red: ko.observableArray([]),
             whiteMove: ko.observable(true),
             selected: null,
         };

         model.currentMove = ko.dependentObservable(
             function() {
                 return this.whiteMove() ? "white" : "red";
             }, model);

         // UI stuff:
         function drawBoard() {
             var i, path = "";

             // ROWS x ROWS grid with path lines
             for (i = 1; i <= ROWS + 1; i++) {
                 path += "M" + (CELL_SIZE * i) + " " + CELL_SIZE + "v" + BOARD_SIZE;
                 path += "M" + CELL_SIZE + " "  + CELL_SIZE * i + "h" + BOARD_SIZE;
             }
             path += "z";
             raphael.path(path).attr("stroke-width", 1);

         }

         function mkChecker(x, y, color) {
             piece = raphael.circle(x, y, RADIUS).attr("stroke-width", 3);
             piece.attr("fill", color);
             piece.attr("cursor", "crosshair");
             piece.team = color;
             piece.node.onclick = makeClickListener(piece);
             return piece;
         }

         function setPieces() {
             var i, x, y;

             // setup new red and white pieces, push them into model
             for (i = 2; i <= ROWS-1; i++) {
                 x = CELL_SIZE * i + CELL_SIZE / 2;

                 y = 3/2 * CELL_SIZE;
                 model.red.push(mkChecker(x, y, "red"));
                 model.white.push(mkChecker(y, x, "white"));

                 y = (ROWS + 1/2) * CELL_SIZE;
                 model.red.push(mkChecker(x, y, "red"));
                 model.white.push(mkChecker(y, x, "white"));

             }
         }

         function makeClickListener(checker) {
             return function(e) {
                 selectChecker(checker)
             };
         }

         function selectChecker(checker) {
             if (model.selected !== null) { model.selected.attr("fill", model.selected.team); }
             checker.attr("fill", "yellow");
             model.selected = checker;
             x0 = (checker.attr("cx") - 75) / 50;
             y0 = 7 - (checker.attr("cy") - 75) / 50;

             // log it temporarily
             console.log(x0, y0);
             console.log(LOA.possibleMoves(x0, y0, LOA.startPosition));
         }

         function init() {
             raphael = Raphael("holder", 500, 500);
             ko.applyBindings(model);
             drawBoard();
             setPieces();
         }

         // public interface
         return {
             init: init,
         };
     };
})();


// main entry point wrapped in jQuery $(...)
$(
    function() {
        LOABoard().init();
    }
);
