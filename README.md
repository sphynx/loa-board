## General info.

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

## How to set up the server locally and contribute to LOA board development.

1. The server side is written in Ruby as a very simple Web application
for [Sinatra][sinatra]. Thus, first we need to install Ruby. In order
not to interact with any system-wide installation of Ruby you already
have, we can install our own sandboxed version of Ruby. We can do this
using `rbenv` tool.

    Use you package manager to install `rbenv`, for further details
please see [here][rbenv]. You can also do the same with [RVM][rvm].

2. Then when we have `rbenv`, we can install a version of Ruby plus
Ruby gems needed for LOA board server. First, Ruby itself:

        rbenv install 2.0.0-p353

3. Then we need to install the following Ruby gems:

        gem install sinatra thin shotgun

4. The client side is written in Coffee Script (a language which is
compiled to JavaScript and basically just provides some syntactics
sugar around JavaScript to make it more pleasant to read and write).
So we will need to install [CoffeeScript][coffee] compiler as well.
Please take a look at its web page to learn how to install it (you'll
need [Node.JS][nodejs] for it ;)).

5. Finally, we can start our own web server and start serving the LOA
board application locally! To do this, run:

        rake serve

    You should see something like this:

        sphynx@fanorona $ rake serve
        shotgun app.rb
        == Shotgun/Thin on http://127.0.0.1:9393/
        Thin web server (v1.6.1 codename Death Proof)
        Maximum connections set to 1024
        Listening on 127.0.0.1:9393, CTRL+C to stop

6. Then you open your browser and go to http://127.0.0.1:9393/ to open
LOA board. If you want to load a game from LittleGolem, you can use
the following address (with a particular game ID from LittleGolem):

    http://127.0.0.1:9393/lg/1734189

7. If you want to change the client code and immediately see the
results (by hust reloading the page in browser), we can run the
following Rake task to start on-the-fly recompiling of CoffeeScript
code:

        rake coffee_fly

8. Then, we can, for example, go to `coffee/board.coffee` source file,
   open it in your favourite editor and change the color of black
   pieces to be actually black:

        BLACK_CHECKER_COLOR = "black"

9. If you have your tasks (`rake coffee_fly` and `rake serve`) running
in the background then you can just reload the page in the browser to
see immediate effect (the color should be changed from red to black).

10. There are other useful Rake tasks, for example `rake test` which
runs tests and opens the test report. You can get the full list of
tasks using `rake -D`.

11. Please feel free to contribute via GitHub pull requests any
features from TODO list or anything else you'd like to improve.

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
[rbenv]:      https://github.com/rbenv/rbenv
[rvm]:        https://rvm.io
[nodejs]:     https://nodejs.org/en/
