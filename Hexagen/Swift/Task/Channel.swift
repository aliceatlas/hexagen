  /*****\\\\
 /       \\\\    Hexagen/Swift/Task/Channel.swift
/  /\ /\  \\\\   Part of Hexagen
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class Channel<T> {
    private let operationQueue = dispatch_queue_create("ai.atlas.hexagen.channel", nil)
    private let bufferSize: Int
    private var bufferSpace: Int
    private let buffer = SynchronizedQueue<T>()
    private let waitingReceivers = SynchronizedQueue<T -> Void>()
    private let waitingSenders = SynchronizedQueue<TaskProto>()
    
    public init(buffer: Int = 0) {
        bufferSize = buffer
        bufferSpace = buffer
    }
    
    internal func sync(operation: Void -> Void) {
        dispatch_sync(operationQueue, operation)
    }
    
    public func send(val: T) {
        var wait = false
        sync {
            if !self.waitingReceivers.isEmpty {
                let recv = self.waitingReceivers.pull(queue: false)!
                recv(val)
            } else {
                self.bufferSpace--
                self.buffer.push(val, queue: false)
                if self.bufferSpace < 0 {
                    self.waitingSenders.push(TaskCtrl.currentTask!)
                    wait = true
                }
            }
        }
        if wait {
            TaskCtrl.suspend()
        }
    }
    
    public func receive() -> T {
        var wait = false
        var ret: T?
        sync {
            if !self.buffer.isEmpty {
                self.bufferSpace++
                ret = self.buffer.pull(queue: false)!
                if self.bufferSpace <= 0 {
                    let sender = self.waitingSenders.pull(queue: false)!
                    sender.schedule()
                }
            } else {
                let task = TaskCtrl.currentTask!
                self.waitingReceivers.push({ ret = $0; task.schedule() }, queue: false)
                wait = true
            }
        }
        if wait {
            TaskCtrl.suspend()
        }
        return ret!
    }
}

extension Channel: Awaitable {
    public func await() -> T {
        return receive()
    }
}

extension Channel: SendAwaitable {
    public func awaitSend(val: T) {
        send(val)
    }
}