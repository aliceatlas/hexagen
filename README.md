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

        * Channel: for a style of communication between tasks largely inspired by Go's channels and Goroutines
        * Promise: allows any number of tasks to await a potentially pending result and awakens all of them when one becomes available
        * Timer: actually just a Promise<Void> that is marked as fulfilled at a specified time

* 98% elegant! Hexagen now features fewer abominations than ever.


Warnings
--------

* Hexagen is in early development and pretty experimental to begin with, don't count on the API not changing drastically.

* Hexagen is written for Swift 1.2, introduced as of Xcode 6.3 (currently in beta). I haven't tried it in earlier versions, but it probably wouldn't work and it would probably be straightforward to make it work.

* Your coroutines should always exit by returning — you can leave them hanging but you will leak memory. With Swift's lack of exceptions and use of ARC instead of garbage collection, I don't currently see a way to unilaterally tell a coroutine to terminate but still clean up after itself.

* This approach has turned out to be very surprisingly low on complications so far, but the whole thing is still a sketchy self-indulgent hack that violates some basic assumptions that almost all existing Objective-C and Swift code can expect to safely make. It's hard to say what potential interactions I might be overlooking, particularly given that the Swift toolchain is still closed-source. *At least* for now, I strongly discourage using this anywhere near production code unless you are very, very silly and reasonably confident that you are already going to hell.

* If you are under the age of 180 or find this framework offensive, please don't look at it.

Notes
-----

* Currently Promises as implemented here are fulfill-only, i.e. there isn't a separate path for errors to take, like there tends to be in other languages' implementations of Promises. This is meant to mirror Swift's overall approach to error handling: to the extent that you need to write Promises that can express error conditions, you should encode that in your own types.

Ideas/Todo
----------

* Library components
    * Select
    * Timeouts
    * Read-only and write-only views of channels (and promises?)
    * Elegant task-aware I/O API
    * Subscribe to Cocoa events, notifications, key-value observing, etc. via Promises/PromiseSequences
    * Bridges to and from Hexagen features for existing widely-used Swift/Objective-C concurrency libraries/frameworks/approaches
* Project quality
    * Unit tests
    * Benchmarks
    * More examples, better organized examples

Colophon
--------

Hexagen is released under an MIT license (see LICENSE.md), allowing you to use and redistribute it pretty much however you want. Hexagen no longer has any external dependencies that don't come standard with Xcode nor incorporates any code from external libraries. Hexagen is best viewed in Netscape Navigator 3.0 or later or earlier and is safe to use even at very high altitudes. Hexagen is written by [Alice Atlas](https://github.com/aliceatlas) at the bidding of spirits that whisper divine mysteries to her as she sits hovering two feet above the floor thinking about the ocean.