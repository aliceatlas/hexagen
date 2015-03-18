  /*****\\\\
 /       \\\\    Swift/Promise.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class Promiselike<T> {
    internal var value: T?
    
    public func map<U>(fn: T -> U) -> Promiselike<U> {
        return MappedPromise(parent: self, fn: fn)
    }
    
    public func addHandler(fn: T -> Void) {
        fatalError("not implemented")
    }
}

public class Promise<T>: Promiselike<T> {
    private var handlers: [T -> Void]? = []
    
    public override init() {}
    
    public override func addHandler(fn: T -> Void) {
        handlers!.append(fn)
    }
    
    internal func _fulfill(value: T) {
        if self.value != nil {
            fatalError("promise was already fulfilled")
        }
        self.value = value
        for handler in handlers! {
            handler(value)
        }
        handlers = nil
    }
}

public class MappedPromise<T, U>: Promiselike<U> {
    internal var parent: Promiselike<T>
    internal var fn: T -> U
    private var addedParentHandler: dispatch_once_t = 0
    private var handlers: [U -> Void]? = []
    
    private init(parent: Promiselike<T>, fn: T -> U) {
        self.parent = parent
        self.fn = fn
    }
    
    private func _parentHandler(value: T) {
        let mappedValue = fn(value)
        self.value = mappedValue
        for handler in handlers! {
            handler(mappedValue)
        }
        handlers = nil
    }
    
    public override func addHandler(fn: U -> Void) {
        handlers!.append(fn)
        dispatch_once(&addedParentHandler) {
            self.parent.addHandler(self._parentHandler)
        }
    }
}

/* currently needs to go here rather than Task/Promise+Awaitable.swift due to Mysterious Compiler Crash reasons */

extension Promiselike: Awaitable {
}

extension Promise: SendAwaitable {
}