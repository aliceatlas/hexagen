  /*****\\\\
 /       \\\\    Swift/Task/Awaitable.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


prefix operator <- {}
prefix operator ?- {}
prefix operator ?<- {}

infix operator <- {
    associativity none
    precedence 90
}


// These don't strictly have to "await" anything, in that the intended conceptual scope here does includes implementations that may return immediately, in addition to those that suspend the task and return after it is resumed; they only need to not actually block the thread.
public protocol Awaitable {
    typealias ValueType
    func _await() -> ValueType
    var _hasValue: Bool { get }
}

public protocol SendAwaitable {
    typealias SendType
    func _awaitSend(SendType)
}

public prefix func <- <T: Awaitable> (source: T) -> T.ValueType {
    return source._await()
}

public prefix func ?- <T: Awaitable> (source: T) -> Bool {
    return source._hasValue
}

public prefix func ?<- <T: Awaitable> (source: T) -> T.ValueType? {
    return ?-source ? <-source : nil
}

public func <- <T: SendAwaitable> (sink: T, val: T.SendType) {
    sink._awaitSend(val)
}


public protocol AwaitableRep {
    typealias AwaitType: Awaitable
    var _asAwaitable: AwaitType { get }
}

public prefix func <- <T: AwaitableRep> (source: T) -> T.AwaitType.ValueType {
    return <-source._asAwaitable
}

public prefix func ?- <T: AwaitableRep> (source: T) -> Bool {
    return ?-source._asAwaitable
}
  
public prefix func ?<- <T: AwaitableRep> (source: T) -> T.AwaitType.ValueType? {
    return ?<-source._asAwaitable
}
