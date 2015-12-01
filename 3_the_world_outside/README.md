# The World Outside

The Elm Architecture is great, but often we need to do things outside the model-update-view flow. Ajax calls to third-party APIs and integrating with pure-JavaScript libraries are common requirements.

## Effects

Anything that happens outside the model-update-view flow is a *side-effect*. Elm offers a parallel data flow using the `elm-effects` library. StartApp (as opposed to StartApp.Simple, which we used in the [Elm Architecture example](../2_the_elm_architecture)) allows us to send requests into the Effects flow during the update phase and receive any results in the Elm Architecture flow as a new action. These actions are treated exactly the same as any other action, so it integrates seamlessly with the rest of the Elm Architecture.

## Ports

Effects don't execute in the main flow of our program. They are passed to a `port`: an isolated connector to the world outside the Elm Architecture.

## Effects into Actions

One nice thing about using Effects with StartApp is that the results are automatically handed back to the `update` function.

A gotcha is that the `update` function requires an Action as input, but Effects typically don't return Actions, they return an arbitrary data type.

For example, using the [Http.get](https://github.com/evancz/elm-http) function to talk to an API might return a chunk of JSON which must be decoded before it can be used, then that result needs to be wrapped in an Action that `update` knows how to handle.

Our example doesn't need to decode any JSON, but it does need to manually-convert the string sent by JavaScript to a `Like` action.

## Signals

Another new concept is `Signals`, which are values that can change over time. They are similar to Node's streams, in that they can be chained together to make more-complex and useful behaviors.

Inputs and outputs to ports are signals, so to tie into them we need to connect our update to them explicitly.

Let's walk through the Effects flow in both directions to see how this happens.

## The Effects Flow (Outgoing)

To log our actions out to JavaScript, we want to add a `log` hook to our `update` function, which will wrap the Effect-creation logic. The problem is, the standard `StartApp.start` function takes an `update` argument that expects exactly two arguments (an action and a model), but adding the log would create a function that takes three args. What to do?

To get the hook, we [partially-apply](https://en.wikipedia.org/wiki/Partial_application) the `update` function when we supply it to `StartApp.start`. This stores the logger (which is also partially-applied) in a single-argument form that we can call easily from inside the `update` function.

Another difference from `StartApp.Simple` is that the return value from the `update` function is no longer just the model, it's a tuple containing the model and a 2nd argument that contains any Effects we would like run. For `Like` and `Reset` actions, that Effect is built by the `log` function, but for the `NoOp` action we pass back `Effects.none` which tells Elm "this action has no side-effects". This is a great feature, because actions explicitly declare whether they do anything other than just update the model, preventing the "hidden update" vulnerability common to most JS apps. No more asking "where did variable x get set to *that* value?"

In the `log` function we see an example of Elm's pipeline syntax. the `|>` takes the result of the left-side expression and supplies it as the last argument to the right-side expression. This allows us to chain data operations together in an easily-readable way without creating temporary variables or resorting to an "inside-out" approach like Effects.task( Task.map ( Signal.send ) ).

The `log` function starts by defining the behavior we want (sending a stringified version of the number of likes to the outbox signal). `Signal.send` returns a `Task`, which is an asynchronous unit of work similar to a JavaScript Promise. Unfortunately, when the Task executes it returns an empty tuple. In order to feed it back into the `update` function, we use `Task.map` to convert that useless return value into a `NoOp` action, which `update` will happily consume. The last step is to convert the Task into an Effect using the `Effects.task` function.

Wrapping a Task in an Effect is like wrapping a letter (the Task) in an envelope (the Effect) which allows it to flow through the postal system. At its destination, we rip open the envelope and read the letter inside. When we hand back a list of Effects to StartApp, it knows how to process them via a dedicated port and return the result back to the update function as an action.

It's important to note that `Signal.send` is not actually called at this point: we are defining the behavior we want, but it won't be executed until after the view is processed and StartApp runs the Effects flow.

The `Signal` we're sending the message to is called `outbox` and it is a `Mailbox`, which is a special signal with an `address` function that accepts inputs. Mailboxes allow us to explicitly send data into a Signal chain. Whatever is sent to the `address` function is emitted to whichever signals are chained behind it. The definition of `outbox` shows that we initialize the signal with an empty string.

The `logger` port is our outgoing connection to the outside world. The body of an outgoing port is a reference to the output of a signal, which is the `signal` function. Since we're listening to `outbox`, the body is `outbox.signal`. Every time the outbox emits a new value, it will be echoed to the port, which in turn echoes it to the outside world (i.e., JavaScript).

Switching to the `script` section of `index.html` for a moment, we can see how to grab data from Elm signals using `subscribe`. `elm.ports.logger.subscribe` means "execute the following JS callback whenever the Elm port named `logger` emits a new value". The data supplied by the port will be available as the first argument to the function, and we can treat it as a normal JavaScript value from there. Here, we echo it to the console.

## The Effects Flow (Incoming)

Remaining in `index.html` for another moment, just below this code is a `elm.ports.jsLikes.send("Like")` call. This sends the string "Like" to the Elm port named `jsLikes` every time the `js-like` JavaScript button is clicked.

Note that Elm does not execute JavaScript code and JavaScript does not execute Elm code. They merely transmit messages back and forth, leaving the destination system to determine the correct response.

Back inside `Main.elm`, let's see how the `jsLikes` port brings that "Like" string back into the Elm flow. 

Incoming ports don't need a body, just a [type annotation](http://elm-lang.org/guide/model-the-problem#contracts) that defines what type of data they can pass. Incoming ports automatically create a signal of the same name that emits new values whenever the port receives a message from JavaScript.

However, the `jsLikes` signal emits strings, not actions. The `jsLikesActions` signal listens to the `jsLikes` signal and uses `Signal.map` to replace whatever comes in from the port with a `Like` action. In this example, we don't care about the actual value passed back by jsLikes, but if we did, we could include it in our Action and `update` would receive it just like any other action.

The final piece to the puzzle is a new argument to `StartApp.start`: the `inputs` array. This contains any signals that we want routed into the model-update-view workflow, so we add the jsLikesActions signal here. Anything emitted by the signals in this list will be dropped directly into the `update` function as an action, which is why we needed to convert the signal's return value from a string to a `Like` action beforehand.

## Type Annotations

A quick aside about all those `outbox : Signal.Mailbox String` and `port tasks : Signal (Task Never ())` lines in the Signals section: those are [type annotations](http://www.cultivatehq.com/posts/phoenix-elm-5/), which are optional in most Elm definitions, but required when you're defining signals, so Elm knows precisely what kind of data will be flowing through the system.

I generally prefer to have annotations for every function, because `explicit > implicit`, but this example is large enough already, so I've only used them where they're required.
