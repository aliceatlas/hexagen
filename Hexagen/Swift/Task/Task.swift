  /*****\\\\
 /       \\\\    Hexagen/Swift/Task/Task.swift
/  /\ /\  \\\\   Part of Hexagen
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


private var mainQueue: dispatch_queue_t { return dispatch_get_main_queue() }

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
    
    public class func suspend() {
        currentTask!.yield()
    }
}

public class Task<T>: TaskProto {
    private let queue: dispatch_queue_t
    private var coro: SimpleGenerator<Void>!
    private var completionPromise = Promise<T>()
    
    public init(queue: dispatch_queue_t = mainQueue, body: Void -> T) {
        self.queue = queue
        super.init()
        coro = SimpleGenerator { [unowned self] yield in
            self.yield = yield
            let result = body()
            self.completionPromise <- result
        }
        schedule()
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

extension Task: Awaitable {
    public func _await() -> T {
        return <-completionPromise
    }
    
    public var _hasValue: Bool {
        return ?-completionPromise
    }
}

}