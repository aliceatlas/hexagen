  /*****\\\\
 /       \\\\    Hexagen/Swift/Task/Promise.swift
/  /\ /\  \\\\   Part of Hexagen
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class Promiselike<T>: Awaitable {
    public func await() -> T {
        fatalError("not implemented")
    }
    
    public func map<U>(fn: T -> U) -> Promiselike<U> {
        return MappedPromise(inner: self, fn: fn)
    }
}

public class MappedPromise<T, U>: Promiselike<U> {
    private var inner: Promiselike<T>
    private var fn: T -> U
    
    private init(inner: Promiselike<T>, fn: T -> U) {
        self.inner = inner
        self.fn = fn
    }
    
    public override func await() -> U {
        return fn(inner.await())
    }
}

public class Promise<T>: Promiselike<T> {
    private var value: T?
    private var waitingListeners: [Task]? = []
    
    public override init() {}
    
    public override func await() -> T {
        if value == nil {
            waitingListeners!.append(Task.currentTask!)
            Task.suspend()
        }
        return value!
    }
    
    public func fulfill(value: T) {
        if self.value != nil {
            fatalError("can't call fulfill() more than once on the same promise")
        }
        self.value = value
        for task in waitingListeners! {
            task.schedule()
        }
        waitingListeners = nil
    }
}

extension Promise: SendAwaitable {
    public func awaitSend(value: T) {
        fulfill(value)
    }
}