# Imports
regex = Parsimmon.regex
digits = Parsimmon.digits
seq = Parsimmon.seq
str = Parsimmon.string
ows = Parsimmon.optWhitespace
skip = Parsimmon.skip

# Helpers
ord = (c) -> c.charCodeAt(0)
lexeme = (p) -> p.skip(ows)

# Parsers

# Move (a ply, more precisely)
file = regex(/[a-i]/i).map((c) -> ord(c.toLowerCase()) - ord "a")
rank = regex(/[1-9]/i).map((c) -> parseInt(c) - 1)

field = lexeme(seq([file, rank])
              .map((res) -> i: res[0], j: res[1]))

moveNumber = lexeme(regex(/[0-9]+\./))

separator = regex /\s*[-x]\s*/

okMove = lexeme(seq([field, separator, field])
             .map((res) -> from: res[0], to: res[2]))

resignMove = lexeme (str("resign"))
move = okMove.or(resignMove)

# Result
whiteWon = str "1-0"
blackWon = str "0-1"
draw = str "1/2-1/2"
inProgress = str "*"
gameResult = lexeme(whiteWon.or(blackWon).or(draw).or(inProgress))

# Numbered move (2 plies or 1 ply with the game result)
numberedOkMove =
  lexeme(seq([moveNumber, move, move])
        .map((res) -> [res[1], res[2]]))

numberedLastPly =
  lexeme(seq([moveNumber, move, gameResult])
        .map((res) -> [res[1]]))

numberedLastMove =
  lexeme(seq([moveNumber, move, move, gameResult])
        .map((res) -> [res[1], res[2]]))

numberedMove = numberedLastMove.or(numberedOkMove).or(numberedLastPly)

moves = numberedMove.atLeast(1)

# Tags
tagName = lexeme(regex(/[a-zA-Z]+/))
tagValue = lexeme(regex(/"[^"]+"/))
tag = lexeme(seq [str("["), tagName, tagValue, str("]")])
tags = tag.many()

# Game
game = ows
  .then(tags)
  .then(moves)
  .map((res) -> _.flatten(res))

games = game.atLeast(1)

# API
global = this
global.PGN =
  parseMove: (str) -> move.parse(str)
  parseGame: (pgn) -> game.parse(pgn)
  parseGames: (pgn) -> games.parse(pgn)

