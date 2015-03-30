  /*****\\\\
 /       \\\\    Swift/Task/Task.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


private protocol TaskProto: AnyObject {
    func schedule()
    func suspend()
}


public class TaskCtrl {
    private static let currentTaskKey = "ai.atlas.hexagen.task.current"
    
    private class var currentTask: TaskProto? {
        get {
            return threadDictionary[currentTaskKey] as? TaskProto
        }
        set(val) {
            if val == nil {
                threadDictionary.removeObjectForKey(currentTaskKey)
            } else {
                threadDictionary[currentTaskKey] = val
            }
        }
    }
    
    public class func suspend<T>(@noescape fn: ((T -> Void) -> Void)) -> T {
        return suspender(fn)()
    }
    
    public class func suspender<T>(@noescape fn: ((T -> Void) -> Void)) -> (Void -> T) {
        let task = currentTask!
        var ret: T!
        func resume(value: T) {
            ret = value
            task.schedule()
        }
        fn(resume)
        func suspend() -> T {
            task.suspend()
            return ret
        }
        return suspend
    }
}


public func Async_(queue: dispatch_queue_t = mainQueue, start: Bool = true, body: Void -> Void) -> Async<Void> {
    return Async(queue: queue, start: start, body: body)
}

public class Async<T>: TaskProto, AwaitableRep {
    private let queue: dispatch_queue_t
    private var coro: Gen<Void>!
    private var yield: (Void -> Void)!
    public let _asAwaitable: Promise<T>
    public var started: Bool { return coro.started }
    
    public init(queue: dispatch_queue_t = mainQueue, start: Bool = true, body: Void -> T) {
        self.queue = queue
        _asAwaitable = Promise()
        coro = Gen { [unowned self] yield in
            self.yield = yield
            self._asAwaitable._fulfill(body())
        }
        if start {
            schedule()
        }
    }
    
    public func start() {
        if started {
            fatalError("can't call start() twice on the same task")
        }
        schedule()
    }
    
    private func enter() {
        //should only be called as a GCD block
        TaskCtrl.currentTask = self
        coro.next()
        TaskCtrl.currentTask = nil
    }
    
    private func schedule() {
        dispatch_async(queue, enter)
    }
    
    private func suspend() {
        yield()
    }
}