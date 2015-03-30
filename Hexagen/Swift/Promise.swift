  /*****\\\\
 /       \\\\    Swift/Promise.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class Promiselike<T> {
    private var handlers: [T -> Void]? = []
    
    internal var value: T? {
        fatalError("not implemented")
    }
    
    public func map<U>(fn: T -> U) -> MappedPromise<T, U> {
        return MappedPromise(parent: self, mapping: fn)
    }
    
    public func addHandler(fn: T -> Void) {
        handlers!.append(fn)
    }
    
    private func callHandlers() {
        let value = self.value!
        for handler in handlers! {
            handler(value)
        }
        handlers = nil
    }
}

public class Promise<T>: Promiselike<T> {
    private var _value: T?
    override internal var value: T? { return _value }
    
    internal override init() {}
    
    public init(@noescape _ fn: (T -> Void) -> Void) {
        super.init()
        fn(_fulfill)
    }
    
    internal func _fulfill(value: T) {
        if _value != nil {
            fatalError("promise was already fulfilled")
        }
        _value = value
        callHandlers()
    }
}

public class MappedPromise<T, U>: Promiselike<U> {
    private var parent: Promiselike<T>
    private var mapping: T -> U
    private var addedParentHandler: dispatch_once_t = 0
    private var cachedValue: U?
    override internal var value: U? {
        if cachedValue == nil && parent.value != nil {
            cachedValue = mapping(parent.value!)
        }
        return cachedValue
    }
    
    private init(parent: Promiselike<T>, mapping: T -> U) {
        self.parent = parent
        self.mapping = mapping
    }
    
    private func _parentHandler(value: T) {
        callHandlers()
    }
    
    public override func addHandler(handler: U -> Void) {
        super.addHandler(handler)
        dispatch_once(&addedParentHandler) {
            self.parent.addHandler(self._parentHandler)
        }
    }
}

/* currently needs to go here rather than Task/Promise+Awaitable.swift due to Mysterious Compiler Crash reasons */

extension Promiselike: Awaitable {
}
