  /*****\\\\
 /       \\\\    Hexagen/Swift/Task/Timer.swift
/  /\ /\  \\\\   Part of Hexagen
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public func Timer(seconds: Double, queue: dispatch_queue_t = mainQueue) -> Promise<Void> {
    let promise = Promise<Void>()
    let nsec = UInt64(seconds * Double(NSEC_PER_SEC))
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(nsec)), queue) {
        promise <- ()
    }
    return promise
}