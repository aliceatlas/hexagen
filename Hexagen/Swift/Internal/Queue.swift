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

internal class SynchronizedQueue<T>: _SyncTarget {
    private var front: Node<T>?
    private weak var back: Node<T>?
    
    private(set) internal var count = 0
    
    internal func push(val: T, sync real: Bool = true) {
        sync(real) {
            if back == nil {
                front = Node(val)
                back = front
            } else {
                back!.next = Node(val)
                back = back!.next
            }
            count++
        }
    }
    
    internal func pull(sync real: Bool = true) -> T? {
        return sync(real) {
            if front != nil {
                count--
                let val = front!.val
                front = front!.next
                if front == nil { back = nil }
                return val
            }
            return nil
        }
    }
    
    internal func unroll(sync real: Bool = true) -> [T] {
        return sync(real) {
            var out: [T] = []
            out.reserveCapacity(count)
            var node = front
            for i in 0..<count {
                out.append(node!.val)
                node = node!.next
            }
            front = nil
            back = nil
            return out
        }
    }
    
    internal var peek: T? {
        return front?.val
    }
    
    internal var isEmpty: Bool {
        return front == nil
    }
}
