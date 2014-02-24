String::format = ->
  formatted = this
  for arg, i in arguments
    formatted = formatted.replace("{" + i + "}", arg)
  formatted

String::replaceAt = (index, character) ->
  @substr(0, index) + character + @substr(index + character.length)
