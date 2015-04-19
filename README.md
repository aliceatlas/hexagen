Hexagen
=======

True coroutines for Swift, and several familiar concurrency structures built on top of them.

Features
--------

* Very little boilerplate for most use cases. (Largely made possible by Swift's type inference.)

* Simple unidirectional and bidirectional generator functions, as in Python, C#, ECMAscript 6, etc.:

  ```swift
  let counter = { (n: Int) in Gen<Int> { yield in
      for i in 0..<n {
          yield(i)
      }
  }}

  for i in counter(5) {
      println(i)
  }
  ```

* Interruptible Grand Central Dispatch task API allowing you to write asynchronous code in straightforward blocking style. When a task is waiting on some event (a timer firing, I/O availability or completion, etc.), instead of blocking the thread, it will suspend itself so its dispatch queue can continue processing tasks. When the event arrives, a block to resume the task is added to its dispatch queue.

    * Included abstractions that know how to seamlessly suspend and resume tasks as needed:

        * Channel: Supports a style of communication between tasks largely inspired by Go's channels and Goroutines.
        * Promise: Allows any number of tasks to await a potentially pending result and awakens all of them when one becomes available.
            * Timer: A Promise<Void> that is marked as fulfilled at a specified time.
            * Feed: A lazily constructed open-ended series of Promises of a given type wrapped in Optional: after receiving a value from a Promise obtained from a Feed, you can get its successor and await the next value, and repeat until nil is returned, indicating that the feed has ended and won't contain any further values. (Feed implements Sequence so you can iterate over it with a for loop, this is often the most straightforward way to use it.)
                * AsyncGen: A Task subclass with additional generator-like behavior — the body function receives a "post" function which is used somewhat like yield, but doesn't actually suspend the task; instead it sends values to an internal Feed, which other tasks can subscribe to by iterating over the task object.

* 98% elegant! Hexagen now features fewer abominations than ever.


Warnings
--------

* Hexagen is in early development and pretty experimental to begin with, don't count on the API not changing drastically.

* Your coroutines should always exit by returning — you can leave them hanging but you will leak memory. With Swift's lack of exceptions and use of ARC instead of garbage collection, I don't currently see a way to unilaterally tell a coroutine to terminate but still clean up after itself.

* The task API needs to account for Cocoa APIs with thread-local behavior in order to make them work coherently and currently doesn't. This may be tricky in the cases of components that don't expose their thread-local variables in any directly manipulable form. Expect it to interact badly with autorelease pools.

* More generally, this approach has turned out to be very surprisingly low on complications so far, but the whole thing is still a sketchy self-indulgent hack that violates some basic assumptions that almost all existing Objective-C and Swift code can expect to safely make. It's hard to say what potential interactions I might be overlooking, particularly given that the Swift toolchain is still closed-source. For now, I strongly discourage using this in production code unless you are very, very silly and reasonably confident that you are already going to hell.

* If you are under the age of 180º or find this framework offensive, please don't look at it.

Notes
-----

* Hexagen is written for Swift 1.2, first available in Xcode 6.3.

* Currently Promises as implemented here are fulfill-only, i.e. there isn't a separate path for errors to take, like there tends to be in other languages' implementations of Promises. This is meant to mirror Swift's overall approach to error handling: to the extent that you need to write Promises that can express error conditions, you should encode that in your own types.

Ideas/Todo
----------

* Library components
    * Select
    * Timeouts
    * Read-only and write-only views of channels (and promises?)
    * Elegant task-aware I/O API
    * Subscribe to Cocoa events, notifications, key-value observing, etc. via Promises/Feeds
    * Bridges to and from Hexagen features for existing widely-used Swift/Objective-C concurrency libraries/frameworks/approaches
    * Task-local storage API
* Project quality
    * Unit tests
    * Benchmarks
    * More examples, better organized examples

### Extra Credit ###

* Side project: implement an alternative framework based on stackless generators (like e.g. Python's built-in yield: a function can only yield from itself to the function that called or most recently reentered it, because it's implemented more like an ordinary function call, getting its own frame on top of the current stack while it's running rather than having a separate stack to switch to).
* Implement exception handling in pure Swift using Hexagen. *(Completing this successfully is worth negative points, and I will grudgingly respect you but never fully trust you.)*

Colophon
--------

Hexagen is released under an MIT license (see LICENSE.md), allowing you to use and redistribute it pretty much however you want. Hexagen no longer has any external dependencies that don't come standard with Xcode nor incorporates any code from external libraries. Hexagen is best viewed in Netscape Navigator 3.0 or later or earlier and is safe to use even at very high altitudes. Hexagen is written by [Alice Atlas](https://github.com/aliceatlas) at the bidding of spirits that whisper divine mysteries to her as she sits hovering two feet above the floor thinking about the ocean.