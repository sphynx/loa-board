Virtual board for playing "Lines of action" abstract board game and
analyzing games from [LittleGolem][lg] gaming site.

Game rules can be read on [Wikipedia][loa].

Currently only standard 8x8 LOA is supported. More variants ("9x9 Black hole", "Scrambled eggs", etc.) and game
servers (BrainKing) should be added later.

The board is implemented in [CoffeeScript][coffee].
The very simple server-side is implemented in Ruby (using [Sinatra][sinatra]).

A set of libraries used so far:

* [Raphaёl][raphael] -- for game graphics and animation.
* [Knockout.js][ko] -- for structuring the code, introducing data model in UI
  using MVVM pattern.
* [jQuery][jquery] -- for querying the DOM.
* [Underscore.js][underscore] -- convenient functional-style helpers.
* [QUnit.js][qunit] -- for unit testing.
* [Bootstrap][bootstrap] -- CSS/JS components.

[LOA]:        http://en.wikipedia.org/wiki/Lines_of_Action
[raphael]:    http://raphaeljs.com
[ko]:         http://knockoutjs.com
[jquery]:     http://jquery.com
[underscore]: http://underscorejs.org
[coffee]:     http://coffeescript.org
[bootstrap]:  http://getbootstrap.com
[sinatra]:    http://www.sinatrarb.com
[lg]:         http://littlegolem.net
[qunit]:      http://qunitjs.com

