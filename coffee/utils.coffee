String::format = ->
  formatted = this
  for arg, i in arguments
    formatted = formatted.replace("{" + i + "}", arg)
  formatted
