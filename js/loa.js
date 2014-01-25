// LOA module contains only pure functions, it does not maintain any
// state (i.e. current board, etc), this is the responsibility of
// calling code. Hence, we do not need a full power of "widget
// pattern" here (described at
// http://peter.michaux.ca/articles/how-i-write-javascript-widgets).
// Instead I use a simpler approach described at:
// http://christianheilmann.com/2007/08/22/again-with-the-module-pattern-reveal-something-to-the-world/

var LOA = function() {

    // Internal constants
    var WHITE = 'w';
    var BLACK = 'b';
    var EMPTY = ' ';

    // PUBLIC stuff
    var startPosition =
        [[" ", "w", "w", "w", "w", "w", "w", " "]
        ,["b", " ", " ", " ", " ", " ", " ", "b"]
        ,["b", " ", " ", " ", " ", " ", " ", "b"]
        ,["b", " ", " ", " ", " ", " ", " ", "b"]
        ,["b", " ", " ", " ", " ", " ", " ", "b"]
        ,["b", " ", " ", " ", " ", " ", " ", "b"]
        ,["b", " ", " ", " ", " ", " ", " ", "b"]
        ,[" ", "w", "w", "w", "w", "w", "w", " "]
        ];

    // returns a list of possible moves [(x,y)] by a given checker on a given board
    // coordinates are 1-based, board is a 2-dimensional array
    function possibleMoves(x1, y1, board) {
        var x0 = x1 - 1;
        var y0 = y1 - 1;

        var checker = board[x0][y0];

        if (checker === EMPTY) {
            return []
        }

        var vertical = verticalAction(x0, y0, board);
        var horizontal = horizontalAction(x0, y0, board);
        var nwDiagonal = nwDiagonalAction(x0, y0, board);
        var neDiagonal = neDiagonalAction(x0, y0, board);

        var moves = [];

        // vertical moves
        if (checkMove(x0, y0, 0, 1, vertical, checker, board)) {
            moves.push([x0, y0 + vertical]);
        }
        if (checkMove(x0, y0, 0, -1, vertical, checker, board)) {
            moves.push([x0, y0 - vertical]);
        }

        // horizontal moves
        if (checkMove(x0, y0, 1, 0, horizontal, checker, board)) {
            moves.push([x0 + horizontal, y0]);
        }
        if (checkMove(x0, y0, -1, 0, horizontal, checker, board)) {
            moves.push([x0 - horizontal, y0]);
        }

        // nw diagonal moves
        if (checkMove(x0, y0, 1, 1, nwDiagonal, checker, board)) {
            moves.push([x0 + nwDiagonal, y0 + nwDiagonal]);
        }
        if (checkMove(x0, y0, -1, -1, nwDiagonal, checker, board)) {
            moves.push([x0 - nwDiagonal, y0 - nwDiagonal]);
        }

        // ne diagonal moves
        if (checkMove(x0, y0, 1, -1, neDiagonal, checker, board)) {
            moves.push([x0 + nwDiagonal, y0 - neDiagonal]);
        }
        if (checkMove(x0, y0, -1, 1, neDiagonal, checker, board)) {
            moves.push([x0 - neDiagonal, y0 + neDiagonal]);
        }

        return moves;
    }


    function checkMove(x0, y0, dx, dy, action, color, board) {

        var oppo = otherColor(color);

        var columns = board.length;
        var rows = board[x0].length;

        var i = x0;
        var j = y0;
        var a = 0;

        while (i >= 0 && j >= 0 && i < columns && j < rows && a < action-1) {
            if (board[i][j] === oppo) {
                return false;
            }
            i += dx;
            j += dy;
            a++;
        }

        if (i >= 0 && j >= 0 && i < columns && j < rows) {
            return board[i][j] === EMPTY || board[i][j] === oppo;
        } else {
            return false;
        }
    }

    function otherColor(color) {
        if (color === WHITE) return BLACK;
        if (color === BLACK) return WHITE;
        return EMPTY;
    }

    function verticalAction(x0, y0, board) {
        var action = 0;
        var rows = board[x0].length;
        for (var i = 0; i < rows; i++) {
            if (board[x0][i] !== EMPTY) action++;
        }
        return action;
    }

    function horizontalAction(x0, y0, board) {
        var action = 0;
        var columns = board.length;
        for (var i = 0; i < columns; i++) {
            if (board[i][y0] !== EMPTY) action++;
        }
        return action;
    }

    function nwDiagonalAction(x0, y0, board) {
        var action = 0;

        var columns = board.length;
        var rows = board[x0].length;

        var i = x0;
        var j = y0;
        while (i < columns && j >= 0) {
            if (board[i][j] !== EMPTY) action++;
            i++;
            j--;
        }

        var i = x0;
        var j = y0;
        while (i > 0 && j < rows-1) {
            i--;
            j++;
            if (board[i][j] !== EMPTY) action++;
        }

        return action;
    }

    function neDiagonalAction(x0, y0, board) {
        var action = 0;

        var columns = board.length;
        var rows = board[x0].length;

        var i = x0;
        var j = y0;
        while (i < columns && j < rows) {
            if (board[i][j] !== EMPTY) action++;
            i++;
            j++;
        }

        var i = x0;
        var j = y0;
        while (i > 0 && j > 0) {
            i--;
            j--;
            if (board[i][j] !== EMPTY) action++;
        }

        return action;
    }

    return {
        possibleMoves : possibleMoves,
        startPosition : startPosition,

        // exported only for tests
        // TODO: figure out how to do this properly
        checkMove : checkMove,
        verticalAction : verticalAction,
        horizontalAction : horizontalAction,
        nwDiagonalAction : nwDiagonalAction,
        neDiagonalAction : neDiagonalAction
    };
}();
