# Imports
regex = Parsimmon.regex
digits = Parsimmon.digits
seq = Parsimmon.seq
string = Parsimmon.string
ows = Parsimmon.optWhitespace

# Helpers
ord = (c) -> c.charCodeAt(0)
lexeme = (p) -> p.skip(ows)

# Parsers

# Move (a ply, more precisely)
file = regex(/[a-i]/i).map((c) -> ord(c.toLowerCase()) - ord "a")
rank = regex(/[1-9]/i).map((c) -> parseInt(c) - 1)

field = lexeme(seq([file, rank])
              .map((res) -> i: res[0], j: res[1]))

moveNumber = lexeme(seq([digits, string "."]))

separator = regex /\s*[-x]\s*/

move = lexeme(seq([field, separator, field])
             .map((res) -> from: res[0], to: res[2]))

# Result
whiteWon = string "1-0"
blackWon = string "0-1"
draw = string "1/2-1/2"
inProgress = string "*"
gameResult = lexeme(whiteWon.or(blackWon).or(draw).or(inProgress))

# Numbered move (2 plies or 1 ply with the game result)
numberedFullMove =
  lexeme(seq([moveNumber, move, move])
        .map((res) -> [res[1], res[2]]))

numberedLastMove =
  lexeme(seq([moveNumber, move, gameResult])
        .map((res) -> [res[1]]))

numberedMove = numberedFullMove.or(numberedLastMove)

moves = numberedMove.many()

# Tags
tagName = lexeme(regex(/[a-zA-Z]+/))
tagValue = lexeme(regex(/"[^"]+"/))
tag = lexeme(seq([string("["),
                 tagName,
                 tagValue,
                 string("]")]))
tags = tag.many()

# LittleGolem tags example:
#
# [Event "Tournament loa.mc.2013.jul.2.1"]
# [Site "www.littlegolem.net"]
# [White "Chaosu"]
# [Black "Ivan Veselov"]
# [Result "*"]

# Game
game = tags.then(moves)

# Test
testString = """
[Event "Tournament loa.mc.2013.jul.2.1"]
[Site "www.littlegolem.net"]
[White "Chaosu"]
[Black "Ivan Veselov"]
[Result "*"]
1. f1-f3 a5-c7 2. b1-d3 h7-e7 3. e8-g6 h6-f4 4. g8-g5 h2-d6 5. d1-g4 d6xg6 6. b8-b7 h5-f7 7. c8-f5 h3-h5 8. d3xg6 a6-c6 9. f8-g7 h4-f2 10. d8-d7 a2-c4 11. b7-b6 a3-c5 12. g5xc5 f4-d6 13. g1-g5 a4xd7 14. g7-f6 h5-h6 15. e1-e3 f7-d5 16. f6-e5 c6xf3 17. g6-e4 d7-d4 18. g5xe7 h6-e6 19. e7-f6 a7-b8 20. c1-d1 b8-c8 21. b6-b5 c8-d8 22. c5-a3 d8-d3 23. a3-b2 c7-c5 24. e3-d2 f2-g3 25. d2-e3 d6xd1 26. b2-c2 *
"""

# API
global = this
global.PGN =
  parseMove: (str) -> move.parse(str)
  parseGame: (str) -> _.flatten(game.parse(str))
  test: testString

