# The Elm Architecture

The Elm Architecture is the standard mental model for all Elm programs. It's possible to break out of it, but there are many benefits to following the structure.

Evan Czaplicki has an [extensive walkthrough](https://github.com/evancz/elm-architecture-tutorial) which you should definitely read several times, but here's the "Hello World" of the Elm Architecture: a field that updates based on button clicks.

The entry point for the app is in `Main.elm` and to compile it to JS use `elm make Main.elm --output elm.js`.

## How to think about Elm Apps

The Elm Architecture is built around a model-update-view flow. What does that mean?

Everything is about supporting a `model`. A model is a single data structure that contains all the state for your application: the values of fields, whether things are visible, etc. The Architecture is dedicated to maintaining that state in a maintainable, bug-resistant manner.

The `update` function is about changing the model in response to actions that take place in the app's world: a button click, typing into a text field, getting a response back from an ajax call. It is the *only* place in the app where the model can change. Data in Elm is immutable, so even if we went crazy and tried to update the model somewhere else in the program, Elm wouldn't permit it. This constraint is terrific for maintainability, since there's nothing more frustrating than finding out a variable you depend on was changed in a function that seems completely-unrelated, far off in another part of your program.

The `view` function is about displaying the model to the user: typically by generating HTML that can be supplied to the user's browser.

## The Flow of an Elm Application

When your app is first loaded into a web page, the model is set into an initial state. Our code example is a "Like" page, so the model is simply an integer that stores the number of likes. Our initial state will be a zero.

Next, the model is passed into the view function, which generates HTML from the data. That HTML is sent to the user. The user is now viewing your page.

An interactive app will have controls on the page allowing it to send commands to Elm. These HTML/JS events are converted by Elm into `actions`, which represent valid events that Elm knows about. Our code example has two buttons: a "Like" button and a "Reset" button. Clicking the "Like" button sends a Like action that Elm will respond to by incrementing the model. Clicking "Reset" sends a Reset action that Elm will respond to by setting the model back to its initial value.

The actions are supplied (along with the existing model) to the update function, which contains a conditional that handles all valid actions. It makes a new copy of the model that includes any changes appropriate for that action. The new model is returned to the main Elm flow. Elm will now use the new model and discard the old one.

Finally, the new model is passed into the view function, which regenerates the HTML supplied to the user. The user is now looking at the updated version of the page. Elm is [blazing fast](http://elm-lang.org/blog/blazing-fast-html), so this is typically instantaneous from the user's perspective.

This is the "one-way data flow" first popularized in Facebook's "Flux" architecture, but perfected by Elm. The [redux](https://github.com/rackt/redux) flux tool is a direct port of the Elm Architecture into JavaScript, and [Angular 2](https://github.com/angular/angular) is heavily-inspired by the Elm Architecture.

## What is StartApp?

`StartApp` is a tiny framework that bootstraps the Elm Architecture, allowing you to only write the bits of the Elm Architecture that are unique to your application. It wires them together automatically. It does things like keeping track of the current model, passing it around to the various functions, and supplying an "address" where your controls can send their actions.

`StartApp.Simple`, as you'd expect, is the simple version. `StartApp` itself is a more feature-filled version that you'd use if you need to step outside the Elm Architecture for things like JavaScript interop or making ajax calls to the outside world. We don't need that for this example, so we'll stick with `StartApp.Simple`.
