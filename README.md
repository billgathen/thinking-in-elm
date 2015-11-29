# Thinking in Elm
A series of experiments exploring how to think using the Elm programming language and how it can play nice with JavaScript. To try Elm without installing it on your machine (as well as seeing a bunch of examples) check out [Try Elm](http://elm-lang.org/try)!

This is not intended as an "Elm 101": I gloss over most of the syntax details to focus on how to *think* about Elm applications, in particular the Elm Architecture and JavaScript interop. The [Elm docs](http://elm-lang.org/docs) are a good place to start if you're learning the language from scratch. Either read them through beforehand or use them as a reference when you see a bit of syntax you don't understand.

## The Steps

1. [Why Should I Care About Elm?](0_why_should_i_care)
1. [Hello World](1_hello_world)
1. [The Elm Architecture](2_the_elm_architecture)
1. [The World Outside](3_the_world_outside)
1. [Going Deeper](4_going_deeper)

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
