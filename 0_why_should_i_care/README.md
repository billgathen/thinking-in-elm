# Why Should I Care About Elm?

## What is it?

[Elm](http://elm-lang.org/) is "the best of functional programming in your browser".

## Buzzword-Compliant

1. Pure Functions
1. Statically-Typed
1. Type Inference
1. Immutability Everywhere
1. Data Pipelines
1. Partial Application
1. Modular
1. Blazing Fast
1. One-Way Data Flow ("The Elm Architecture")
1. &lt;whisper&gt;Monads&lt;/whisper&gt;

## Ok, but what is it?

Elm is a descendant of Haskell that transpiles to plain-vanilla JavaScript and runs in any modern browser.

It should run fine in Node as well, but as of December 2015, none of the support materials or current dev effort is focused on this.

The Elm docs advertise "no runtime exceptions" because the compiler is extremely good at catching things like incomplete conditionals (forgetting an else clause), mismatched types or possible nil conditions.

## Any downsides?

Elm is a descendant of Haskell, so unless you have experience in Haskell, some of the concepts are pretty mind-bending. However, my experience has been that once I understood an unfamiliar approach, it's easier and/or more bug-resistant than the "old-school" technique it displaces.

Elm is still pretty new: not all the libraries you're used to in JavaScript have pure-Elm versions, though you should be able to integrate the two for the time being.

It's not particularly-compact in terms of generated JavaScript, though this may improve in the future. The Elm runtime is included in every Elm program, and even for a simple ["Hello World" app](../1_hello_world) the elm.js file is ~11,000 lines and 279K uncompressed. I'm still not clear whether Elm plays nicely with standard minify/compress solutions, but UglifyJS dropped the file size to 178K minified and 170K compressed.
