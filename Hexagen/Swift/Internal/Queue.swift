  /*****\\\\
 /       \\\\    Swift/Internal/Queue.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


private class Node<T> {
    var val: T
    var next: Node<T>?
    
    init(_ val: T) {
        self.val = val
    }
}

internal class SynchronizedQueue<T> {
    private let operationQueue = dispatch_queue_create("ai.atlas.hexagen.synchronizedQueue", nil)
    
    private var front: Node<T>?
    private weak var back: Node<T>?
    
    private var _count = 0
    internal var count: Int { return _count }
    
    internal func sync(queue: Bool, operation: Void -> Void) {
        if queue {
            dispatch_sync(operationQueue, operation)
        } else {
            operation()
        }
    }
    
    internal func push(val: T, queue: Bool = true) {
        sync(queue) {
            if self.back == nil {
                self.front = Node(val)
                self.back = self.front
            } else {
                self.back!.next = Node(val)
                self.back = self.back!.next
            }
            self._count++
        }
    }
    
    internal func pull(queue: Bool = true) -> T? {
        var val: T?
        sync(queue) {
            if self.front != nil {
                self._count--
                val = self.front!.val
                self.front = self.front!.next
                if self.front == nil { self.back = nil }
            }
        }
        return val
    }
    
    internal var peek: T? {
        return front?.val
    }
    
    internal var isEmpty: Bool {
        return front == nil
    }
}
