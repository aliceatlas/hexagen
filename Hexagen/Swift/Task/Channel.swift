  /*****\\\\
 /       \\\\    Swift/Task/Channel.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class Channel<T> {
    private let operationQueue = dispatch_queue_create("ai.atlas.hexagen.channel", nil)
    private let bufferSize: Int
    private lazy var bufferSpace: Int = self.bufferSize
    private let buffer = SynchronizedQueue<T>()
    private let waitingReceivers = SynchronizedQueue<T -> Void>()
    private let waitingSenders = SynchronizedQueue<Void -> Void>()
    
    public init(buffer: Int = 0) {
        bufferSize = buffer
    }
    
    internal func sync(operation: Void -> Void) {
        dispatch_sync(operationQueue, operation)
    }
    
    public func send(val: T) {
        var suspender: (Void -> Void)?
        sync {
            if !self.waitingReceivers.isEmpty {
                let recv = self.waitingReceivers.pull(queue: false)!
                recv(val)
            } else {
                self.bufferSpace--
                self.buffer.push(val, queue: false)
                if self.bufferSpace < 0 {
                    suspender = TaskCtrl.suspender { resume in
                        self.waitingSenders.push(resume)
                    }
                }
            }
        }
        suspender?()
    }
    
    public func receive() -> T {
        var suspender: (Void -> T)?
        var ret: T?
        sync {
            if !self.buffer.isEmpty {
                self.bufferSpace++
                ret = self.buffer.pull(queue: false)!
                if self.bufferSpace <= 0 {
                    let sender = self.waitingSenders.pull(queue: false)!
                    sender()
                }
            } else {
                suspender = TaskCtrl.suspender { resume in
                    self.waitingReceivers.push(resume, queue: false)
                }
            }
        }
        return ret ?? suspender!()
    }
}

extension Channel: Awaitable {
    public func _await() -> T {
        return receive()
    }
    
    public var _hasValue: Bool {
        return !buffer.isEmpty
    }
}

extension Channel: SendAwaitable {
    public func _awaitSend(val: T) {
        send(val)
    }
}