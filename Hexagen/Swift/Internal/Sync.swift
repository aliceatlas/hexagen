  /*****\\\\
 /       \\\\    Swift/Internal/Sync.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


import Foundation
import Dispatch


internal func synchronized<T>(obj: AnyObject, @noescape body: Void -> T) -> T {
    objc_sync_enter(obj)
    let ret = body()
    objc_sync_exit(obj)
    return ret
}

internal func synchronized(obj: AnyObject, @noescape body: Void -> Void) {
    let _: Void? = synchronized(obj) { body(); return nil }
}

public class _SyncTarget {
    internal func sync<T>(_ real: Bool = true, @noescape _ body: Void -> T) -> T {
        if real {
            return synchronized(self, body)
        } else {
            return body()
        }
    }
    
    internal func sync(_ real: Bool = true, @noescape _ body: Void -> Void) {
        let _: Void? = sync(real) { body(); return nil }
    }
}


internal struct DispatchOnce {
    private var flag: dispatch_once_t = 0
    mutating func perform(operation: Void -> Void) {
        dispatch_once(&flag, operation)
    }
}

internal struct ThreadSafeLazy<T> {
    private var _value: T?
    private var shouldSetup = DispatchOnce()
    private var initializer: (Void -> T)?
    
    init(_ initializer: Void -> T) {
        self.initializer = initializer
    }
    
    private mutating func setup() {
        _value = initializer!()
        initializer = nil
    }
    
    private mutating func setupNoInit() {
        initializer = nil
    }
    
    var value: T {
        mutating get {
            shouldSetup.perform(setup)
            return _value!
        }
        set {
            shouldSetup.perform(setupNoInit)
            _value = newValue
        }
    }
}