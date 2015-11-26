# elm-step-by-step
A series of experiments exploring the Elm language and how it can play nice with JavaScript. To try Elm without installing it on your machine (as well as seeing a bunch of examples) check out [Try Elm](http://elm-lang.org/try)!

## The Steps

1. [Hello World](1_hello_world/)
1. [The Elm Architecture](2_the_elm_architecture)
1. [The World Outside](3_the_world_outside)

## Playing with the examples

To play with the examples on Linux/OSX machine:

_NOTE: I don't have instructions for doing Elm development on Windows, but the commands should be similar._

1. [Install Elm](http://elm-lang.org/install)
1. `git clone https://github.com/billgathen/elm-step-by-step.git`

Each project has been compiled, so to try the examples on your local machine, run this command in your terminal in the main directory for the example:

`open index.html`

When you make a change to one of the `.elm` files in any of the examples, run this command in your terminal, in the main directory for the example:

`elm make Main.elm --output elm.js`

That will re-build the Elm application and store it in `elm.js` so the `index.html` page can find it.

The first time you build one of the projects, Elm needs to pull down all the dependencies: accept the defaults for all the questions it asks you.

[LICENSE](LICENSE)
