  /*****\\\\
 /       \\\\    Hexagen/Swift/Task/Promise.swift
/  /\ /\  \\\\   Part of Hexagen
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class Promiselike<T>: Awaitable {
    public func _await() -> T {
        fatalError("not implemented")
    }
    
    public var _hasValue: Bool {
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
    
    public override func _await() -> U {
        return fn(<-inner)
    }
    
    public override var _hasValue: Bool {
        return ?-inner
    }
}

public class Promise<T>: Promiselike<T> {
    private var value: T?
    private var waitingListeners: [TaskProto]? = []
    
    public override init() {}
    
    public override func _await() -> T {
        if value == nil {
            waitingListeners!.append(TaskCtrl.currentTask!)
            TaskCtrl.suspend()
        }
        return value!
    }
    
    public override var _hasValue: Bool {
        return value != nil
    }
    
    public func _fulfill(value: T) {
        if self.value != nil {
            fatalError("promise was already resolved")
        }
        self.value = value
        for task in waitingListeners! {
            task.schedule()
        }
        waitingListeners = nil
    }
}

extension Promise: SendAwaitable {
    public func _awaitSend(value: T) {
        _fulfill(value)
    }
}