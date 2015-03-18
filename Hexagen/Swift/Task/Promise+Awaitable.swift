  /*****\\\\
 /       \\\\    Swift/Task/Promise+Awaitable.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


extension Promiselike {
    public func _await() -> T {
        return value ?? TaskCtrl.suspend(addHandler)
    }
    
    public var _hasValue: Bool {
        return value != nil
    }
}
