  /*****\\\\
 /       \\\\    Swift/Task/Task.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class TaskProto {
    private var yield: (Void -> Void)!
    
    internal func schedule() {
        fatalError("not implemented")
    }
}


public class TaskCtrl {
    private static let currentTaskKey = "ai.atlas.hexagen.task.current"
    
    public class var currentTask: TaskProto? {
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
        var ret: T?
        func resume(value: T) {
            ret = value
            task.schedule()
        }
        fn(resume)
        func suspend() -> T {
            task.yield()
            return ret!
        }
        return suspend
    }
}


public func Async_(queue: dispatch_queue_t = mainQueue, start: Bool = true, body: Void -> Void) -> Async<Void> {
    return Async(queue: queue, start: start, body: body)
}

public class Async<T>: TaskProto {
    private let queue: dispatch_queue_t
    private var coro: Gen<Void>!
    private var completionPromise = Promise<T>()
    
    public init(queue: dispatch_queue_t = mainQueue, start: Bool = true, body: Void -> T) {
        self.queue = queue
        super.init()
        coro = Gen { [unowned self] yield in
            self.yield = yield
            let result = body()
            self.completionPromise <- result
        }
        if start {
            schedule()
        }
    }
    
    internal override func schedule() {
        dispatch_async(queue, enter)
    }
    
    private func enter() {
        //should only be called as a GCD block
        TaskCtrl.currentTask = self
        coro.next()
        TaskCtrl.currentTask = nil
    }
}

extension Async: Awaitable {
    public func _await() -> T {
        return <-completionPromise
    }
    
    public var _hasValue: Bool {
        return ?-completionPromise
    }
}