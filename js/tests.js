
// LOA API we want to test:

/*
function parsePosition(rows)
function possibleMoves(x1, y1, board)
function checkMove(x0, y0, dx, dy, action, color, board)
function otherColor(color)
function verticalAction(x0, y0, board)
function horizontalAction(x0, y0, board)
function nwDiagonalAction(x0, y0, board)
function neDiagonalAction(x0, y0, board)
*/

// HELPERS


var emptyPosStr =
  [ "........"
  , "........"
  , "........"
  , "........"
  , "........"
  , "........"
  , "........"
  ];

var termPosStr =
  [ "........"
  , "ww......"
  , ".....w.."
  , ".w.b...."
  , "..wb.b.."
  , ".bb.b..."
  , ".....b.."
  , "....w..."
  ];

var termPos = LOA.parsePosition(termPosStr);

var s0Expected =
    [[" ", "w", "w", "w", "w", "w", "w", " "]
    ,["b", " ", " ", " ", " ", " ", " ", "b"]
    ,["b", " ", " ", " ", " ", " ", " ", "b"]
    ,["b", " ", " ", " ", " ", " ", " ", "b"]
    ,["b", " ", " ", " ", " ", " ", " ", "b"]
    ,["b", " ", " ", " ", " ", " ", " ", "b"]
    ,["b", " ", " ", " ", " ", " ", " ", "b"]
    ,[" ", "w", "w", "w", "w", "w", "w", " "]
    ];

var s0 = LOA.startPosition(8,8);

function vert(board, x0, expected) {
    equal(LOA.verticalAction(x0, 0, board), expected,
          "Vertical for start position in row {0}".format(x0));
}

function horiz(board, y0, expected) {
    equal(LOA.horizontalAction(0, y0, board), expected,
          "Horizontal for start position in column {0}".format(y0));
}

function nw(board, x0, y0, expected) {
    equal(LOA.nwDiagonalAction(x0, y0, board), expected,
          "NW diagonal for start position in x0={0}, y0={1}".format(x0, y0));
}

function ne(board, x0, y0, expected) {
    equal(LOA.neDiagonalAction(x0, y0, board), expected,
          "NE diagonal for start position in x0={0}, y0={1}".format(x0, y0));
}

function moves(board, x1, y1, expected) {
    deepEqual(LOA.possibleMoves(x1, y1, board).sort(), expected.sort(),
              "Moves in start position for x1={0} and y1={1}".format(x1, y1));
}

// TESTS

test("Position parsing", function() {
    deepEqual(s0, s0Expected, "start position");
});

test("Vertical actions in start position", function() {
    vert(s0, 0, 6);
    for (var i = 1; i < 7; i++) {
        vert(s0, i, 2);
    }
    vert(s0, 7, 6);
});

test("Horizontal actions in start position", function() {
    horiz(s0, 0, 6);
    for (var i = 1; i < 7; i++) {
        horiz(s0, i, 2);
    }
    horiz(s0, 7, 6);
});

test("NW diagonal actions in start position", function() {
    _.each(_.range(8), function(i) {
        _.each(_.range(8), function(j) {
            var expected =
                ( i === 7-j ||
                 (i === 0 && j === 0) ||
                 (i === 7 && j === 7)) ? 0 : 2;
            nw(s0, i, j, expected);
        })
    });
});

test("NE diagonal actions in start position", function() {
    _.each(_.range(8), function(i) {
        _.each(_.range(8), function(j) {
            var expected =
                ( i === j ||
                 (i === 0 && j === 7) ||
                 (i === 7 && j === 0)) ? 0 : 2;
            ne(s0, i, j, expected);
        })
    });
});

test("Possible moves", function() {
    // no moves from empty cells
    _.each(_.range(8), function(i) {
        moves(s0, i, i, []);
    });
    moves(s0, 1, 2, []);
    moves(s0, 2, 4, []);
    moves(s0, 6, 3, []);

    // normal moves
    moves(s0, 0, 1, [[0,7], [2,1], [2,3]]);
    moves(s0, 1, 0, [[1,2], [3,2], [7,0]]);
    moves(s0, 5, 0, [[3,2], [5,2], [7,2]]);
    moves(s0, 0, 6, [[0,0], [2,4], [2,6]]);
    moves(s0, 7, 3, [[5,1], [5,3], [5,5]]);
});
