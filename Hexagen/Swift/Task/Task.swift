  /*****\\\\
 /       \\\\    Hexagen/Swift/Task/Task.swift
/  /\ /\  \\\\   Part of Hexagen
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class Task {
    private enum Awaitable {
        case Sleep(nanoseconds: UInt64)
        case ChannelSendWait
        case ChannelReceiveWait
        case PromiseWait
    }
    
    private let queue: dispatch_queue_t
    private var coro: SimpleGenerator<Awaitable>!
    private var yield: (Awaitable -> Void)!
    
    private static let currentTaskKey = "ai.atlas.hexagen.task.current"
    public class var currentTask: Task? {
        get {
            return threadDictionary[currentTaskKey] as? Task
        }
        set(val) {
            if val == nil {
                threadDictionary.removeObjectForKey(currentTaskKey)
            } else {
                threadDictionary[currentTaskKey] = val
            }
        }
    }
    
    public init(queue: dispatch_queue_t, body: Void -> Void) {
        self.queue = queue
        coro = SimpleGenerator { yield in
            self.yield = yield
            body()
        }
        schedule()
    }
    
    public convenience init(_ body: Void -> Void) {
        self.init(queue: dispatch_get_main_queue(), body: body)
    }
    
    private func schedule() {
        dispatch_async(queue, enter)
    }
    
    private func enter() {
        //should only be called as a GCD block
        self.dynamicType.currentTask = self
        let req = coro.next()
        self.dynamicType.currentTask = nil
        if let req = req {
            handleOneAwait(req)
        }
    }
    
    private func handleOneAwait(req: Awaitable) {
        switch req {
        case let .Sleep(nanoseconds):
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(nanoseconds)), queue, enter)
        case .ChannelReceiveWait, .ChannelSendWait, .PromiseWait:
            { return }()
        }
    }
    
    internal func scheduleAwakeAfterChannelSendWait() {
        schedule()
    }
    
    internal func scheduleAwakeAfterChannelReceiveWait() {
        schedule()
    }
    
    internal func scheduleAwakeAfterPromiseWait() {
        schedule()
    }
}

public extension Task /* current task control */ {
    public class func sleep(seconds: Double) {
        let nsec = UInt64(seconds * Double(NSEC_PER_SEC))
        currentTask!.yield(.Sleep(nanoseconds: nsec))
    }
    
    internal class func channelSendWait() {
        currentTask!.yield(.ChannelSendWait)
    }
    
    internal class func channelReceiveWait() {
        currentTask!.yield(.ChannelReceiveWait)
    }
    
    internal class func promiseWait() {
        currentTask!.yield(.PromiseWait)
    }
}