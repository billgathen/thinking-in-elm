# The World Outside

The Elm Architecture is great, but often we need to do things outside the model-update-view flow. Ajax calls to third-party APIs and interating with pure-JavaScript libraries are common requirements.

## Effects

Anything that happens outside the model-update-view function is a *side-effect*. Elm offers a parallel data flow using a library called `Effects`. StartApp (as opposed to StartApp.Simple, which we used in the [Elm Architecture example](../2_the_elm_architecture)) allows us to send requests into the Effects flow during the update phase and it sends any results back into the Elm Architecture flow as a new action.

## Ports

Effects don't execute in the main flow of our program: they are passed to `ports`, which are isolated connectors to the world outside the Elm Architecture.
