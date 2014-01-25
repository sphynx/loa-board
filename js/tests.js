
// LOA API we want to test:

/*
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

var s0 = LOA.startPosition;

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


// TESTS

test("Position parsing", function() {
    deepEqual(s0, s0Expected, "start position");
});

test("Vertical in start position", function() {
    vert(s0, 0, 6);
    for (var i = 1; i < 7; i++) {
        vert(s0, i, 2);
    }
    vert(s0, 7, 6);
});


test("Horizontal in start position", function() {
    horiz(s0, 0, 6);
    for (var i = 1; i < 7; i++) {
        horiz(s0, i, 2);
    }
    horiz(s0, 7, 6);
});

test("NW diagonal in start position", function() {
    nw(s0, 0, 0, 0);
    nw(s0, 0, 1, 2);
    nw(s0, 1, 0, 2);
    nw(s0, 1, 1, 2);
    nw(s0, 7, 7, 0);
    nw(s0, 7, 0, 0);
    nw(s0, 2, 3, 2);
});

