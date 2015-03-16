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

        * Channel: for a style of communication between tasks largely inspired by Go's channels and Goroutines)
        * Promise: allows any number of tasks to await a potentially pending result and awakens all of them when one becomes available
        * Timer: actually just a Promise<Void> that is marked as fulfilled at a specified time

* 97% elegant! Very minimal abomination content, you should almost never have to encounter it.


Warnings
--------

* Hexagen is in early development and pretty experimental to begin with, don't count on the API not changing drastically.

* Hexagen is written for Swift 1.2, introduced as of Xcode 6.3 (currently in beta). I haven't tried it in earlier versions, but it probably wouldn't work and it would probably be straightforward to make it work.

* Your coroutines should always exit by returning — you can leave them hanging but you will leak memory. With Swift's lack of exceptions and use of ARC instead of garbage collection, I don't currently see a way to unilaterally tell a coroutine to terminate but still clean up after itself.

* This approach has turned out to be very surprisingly low on complications so far, but the whole thing is still a sketchy self-indulgent hack that violates some basic assumptions that almost all existing Objective-C and Swift code can expect to safely make. It's hard to say what potential interactions I might be overlooking, particularly given that the Swift toolchain is still closed-source. *At least* for now, I strongly discourage using this anywhere near production code unless you are very, very silly and reasonably confident that you are already going to hell.

* If you are under the age of 180 or find this framework offensive, please don't look at it.

Notes
-----

* Building the framework requires Boost and the project currently assumes you've installed it via MacPorts (it will look for /opt/local/include/boost and /opt/local/lib/libboost_{coroutine,system}-mt.a). You will need to change these if you have Boost installed somewhere else. The built framework itself is meant to be standalone, it should be possible to work with the exposed Swift API with no external Boost dependencies.

* Should probably be adapted to use Boost.Context directly once the upcoming version with execution\_context is released and Xcode ships with support for thread\_local in clang and libc++.

* Have not attempted to test any of this with iOS yet.

Ideas/Todo
----------

* Library components
    * Select
    * Timeouts
    * Read-only and write-only views of channels (and promises?)
    * Elegant task-aware I/O API
    * Bridges to and from Hexagen features for existing widely-used Swift/Objective-C concurrency libraries/frameworks/approaches
* Project quality
    * Unit tests
    * Benchmarks
    * More examples, better organized examples

Credits
-------

The underlying context-switching primitive is a tiny wrapper around [Boost.Context](http://www.boost.org/libs/context/), currently via [Boost.Coroutine](http://www.boost.org/libs/coroutine/). Currently no Boost source or binaries are included in this repository, but Boost is free software under a permissive MIT-style [license](http://www.boost.org/users/license.html), Hexagen uses an MIT license, and so for the most part you can pretty freely incorporate and redistribute both with whatever.

My name is [Alice Atlas](https://github.com/aliceatlas) and I wrote the rest of it. I did it on purpose and I'm not sorry, dad