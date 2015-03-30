  /*****\\\\
 /       \\\\    Swift/Promise.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class Promiselike<T> {
    private var handlers: SynchronizedQueue<T -> Void>? = SynchronizedQueue()
    private var shouldDischargeHandlers = DispatchOnce()
    
    internal var value: T? {
        fatalError("not implemented")
    }
    
    public func map<U>(fn: T -> U) -> MappedPromise<T, U> {
        return MappedPromise(parent: self, mapping: fn)
    }
    
    public func addHandler(fn: T -> Void) {
        handlers?.push(fn) ?? fn(value!)
    }
    
    private func dischargeHandlers() {
        var alreadyRan = true
        shouldDischargeHandlers.perform {
            alreadyRan = false
            let value = self.value!
            let handlers = self.handlers!
            self.handlers = nil
            for handler in handlers.unroll() {
                handler(value)
            }
        }
        if alreadyRan {
            fatalError("promise being asked to discharge handlers for a second time")
        }
    }
}

public class Promise<T>: Promiselike<T> {
    private var shouldFulfill = DispatchOnce()
    private var _value: T?
    override internal var value: T? { return _value }
    
    internal override init() {}
    
    public init(@noescape _ fn: (T -> Void) -> Void) {
        super.init()
        fn(_fulfill)
    }
    
    internal func _fulfill(value: T) {
        var alreadyRan = true
        shouldFulfill.perform {
            alreadyRan = false
            printo("FULFILL \(self.sn)")
            self._value = value
            self.dischargeHandlers()
        }
        if alreadyRan {
            fatalError("promise was already fulfilled")
        }
    }
}

public class MappedPromise<T, U>: Promiselike<U> {
    private let parent: Promiselike<T>
    private let mapping: T -> U
    private var shouldAddParentHandler = DispatchOnce()
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
        dischargeHandlers()
    }
    
    public override func addHandler(handler: U -> Void) {
        super.addHandler(handler)
        shouldAddParentHandler.perform {
            self.parent.addHandler(self._parentHandler)
        }
    }
}

}
