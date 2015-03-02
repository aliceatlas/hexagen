  /*****\\\\
 /       \\\\    Hexagen/Swift/Task/Awaitable.swift
/  /\ /\  \\\\   Part of Hexagen
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


prefix operator <- {}
infix operator <- {
    associativity none
    precedence 90
}

// These don't strictly have to "await" anything, in that the intended conceptual scope here does includes implementations that may return immediately, in addition to those that suspend the task and return after it is resumed; they only need to not actually block the thread.
public protocol Awaitable {
    typealias ValueType
    func await() -> ValueType
}
public protocol SendAwaitable {
    typealias SendType
    func awaitSend(SendType)
}

public prefix func <- <T: Awaitable> (source: T) -> T.ValueType {
    return source.await()
}
public func <- <T: SendAwaitable> (sink: T, val: T.SendType) {
    sink.awaitSend(val)
}

