# The World Outside

The Elm Architecture is great, but often we need to do things outside the model-update-view flow. Ajax calls to third-party APIs and interating with pure-JavaScript libraries are common requirements.

## Effects

Anything that happens outside the model-update-view function is a *side-effect*. Elm offers a parallel data flow using a library called `Effects`. StartApp (as opposed to StartApp.Simple, which we used in the [Elm Architecture example](../2_the_elm_architecture)) allows us to send requests into the Effects flow during the update phase and receive any results in the Elm Architecture flow as a new action. These actions are treated exactly the same as any other action, so it integrates seamlessly with the rest of the Elm Architecture.

## Ports

Effects don't execute in the main flow of our program. They are passed to a `port`: an isolated connector to the world outside the Elm Architecture.

## Effects into Actions

One nice thing about using Effects with StartApp is that the results are automatically handed back to the `update` function.

A gotcha is that the `update` function requires an Action as input, but Effects typically don't return Actions, they return an arbitrary data type.

For example, using the [Http.get](https://github.com/evancz/elm-http) function to talk to an API might return a chunk of JSON which must be decoded before it can be used, then that result needs to be wrapped in an Action that `update` knows how to handle.

Our example doesn't need to decode any JSON, but it does need to manually-convert the string sent by JavaScript to a `Like` action.

## Signals

Another new concept is `Signals`, which are values that can change over time. They are similar to Node's streams, in that they can be chained together to make more-complicated and useful behaviors.

Inputs and outputs to ports are signals, so to tie into them we need to connect our update to them explicitly.

## Type Annotations

A quick aside about all those `outbox : Signal.Mailbox String` and `port tasks : Signal (Task Never ())` lines in the Signals section: those are [type annotations](http://www.cultivatehq.com/posts/phoenix-elm-5/), which are optional in most Elm definitions, but required when you're defining signals, so Elm knows precisely what kind of data will be flowing through the system.

I generally prefer to have annotations for every function, because `explicit > implicit`, but this example is large enough already, so I've only used them where they're required.

## The Effects Flow (Outgoing)

To log our actions out to JavaScript, we add a `log` hook to our `update` function, which wraps the Effect-creation logic. To get the hook, we [partially-apply](https://en.wikipedia.org/wiki/Partial_application) the `update` function when we supply it to `StartApp.start`. This stores the logger (which is also partially-applied) in a single-argument form that we can call easily from inside the `update` function.

Another difference from `StartApp.Simple` is that the "model" we pass back from the `update` function is the actual model and a 2nd argument that contains any Effects we would like run. For `Like` and `Reset` actions, that Effect is built by the `log` function, but for the `NoOp` action we pass back `Effects.none` which tells Elm "this action has no side-effects". This is a great feature, because actions explicitly declare whether they do anything other than just update the model, preventing the "hidden update" vulnerability common to most JS apps. No more asking "where did variable x get set to *that* value?"

The `log` function wraps the behavior we want in a `Task` (a unit of work similar to a JavaScript Promise), which is in turn wrapped in an `Effect`, which can be used natively by the `StartApp` workflow. The original behavior is to send a string (the stringified version of the number of likes) to the `outbox` signal (which we'll discuss in a moment). The `Task.map` expression says "take whatever that action returns and return a `NoOp` action instead". `Effects.task` wraps that task in an Effect and returns it to `update`, which returns it to the main flow to be executed after the `view` finishes processing.

The `Signal` we're sending the message to is called `outbox` and it is a `Mailbox`, which is a special signal with an `address` function that accepts inputs. Mailboxes allow us to explicitly send data into a Signal chain. Whatever is sent to the `address` function is emitted to whichever signals are listening. The declaration of `outbox` shows how we initialize the signal with an empty string.

The `logger` port is our outgoing connection to the outside world. The body of an outgoing port is a reference to the output of a signal, which is the `signal` function. Since we're listening to `outbox`, the body is `outbox.signal`. Every time the outbox emits a new value, it will be echoed to the port, which in turn echoes it to the outside world (aka JavaScript).

Switching to the `script` section of `index.html` for a moment, we can see how to grab data from Elm signals using `subscribe`. `elm.ports.logger.subscribe` means "execute the following JS callback whenever the Elm port named `logger` emits a new value". The data supplied by the port will be available as the first argument to the function, and we can treat it as a normal JavaScript value from there. Here, we echo it to the console.

## The Effects Flow (Incoming)

Remaining in `index.html` for another moment, just below this code is a `elm.ports.jsLikes.send("Like")` call. This sends the string "Like" to the Elm port named `jsLikes` every time the `js-like` JavaScript button is clicked.

Note that Elm does not execute JavaScript code and JavaScript does not execute Elm code. They merely transmit messages back and forth, leaving the destination system to determine the correct response.

Back inside `Main.elm`, let's see how the `jsLikes` port brings that "Like" string back into the Elm flow. 

Incoming ports don't need a body, just a declaration that defines what type of data they will receive. Incoming ports automatically create a signal of the same name that emits new values whenever the port receives a message from JavaScript.

However, the `jsLikes` signal emits strings, not actions. The `jsLikesActions` signal listens to the `jsLikes` signal and uses `Signal.map` to replace whatever comes in from the port with a `Like` action. In this example, we don't care about the actual value passed back by jsLikes, but if we did, we could include it in our Action and `update` would receive it just like any other action.

The final piece to the puzzle is a new argument to `StartApp.start`: the `inputs` array. This contains any signals that we want routed into the model-update-view workflow, so we add the jsLikesActions signal here. Anything emitted by the signals in this list will be dropped directly into the `update` function as the action, which is why we needed to convert it from a string into a `Like` action beforehand.
