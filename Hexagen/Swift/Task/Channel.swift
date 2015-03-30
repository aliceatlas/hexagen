  /*****\\\\
 /       \\\\    Swift/Task/Channel.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class Channel<T>: _SyncTarget {
    private let bufferSize: Int
    private lazy var bufferSpace: Int = self.bufferSize
    private let buffer = SynchronizedQueue<T>()
    private let waitingReceivers = SynchronizedQueue<T -> Void>()
    private let waitingSenders = SynchronizedQueue<Void -> Void>()
    
    public init(buffer: Int = 0) {
        bufferSize = buffer
    }
    
    public func send(val: T) {
        var suspender: (Void -> Void)?
        sync {
            if !waitingReceivers.isEmpty {
                let recv = waitingReceivers.pull(sync: false)!
                recv(val)
            } else {
                bufferSpace--
                buffer.push(val, sync: false)
                if bufferSpace < 0 {
                    suspender = TaskCtrl.suspender { resume in
                        waitingSenders.push(resume)
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
            if !buffer.isEmpty {
                bufferSpace++
                ret = buffer.pull(sync: false)!
                if bufferSpace <= 0 {
                    let sender = waitingSenders.pull(sync: false)!
                    sender()
                }
            } else {
                suspender = TaskCtrl.suspender { resume in
                    waitingReceivers.push(resume, sync: false)
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