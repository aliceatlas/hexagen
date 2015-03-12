  /*****\\\\
 /       \\\\    Hexagen/Swift/Task/Task.swift
/  /\ /\  \\\\   Part of Hexagen
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
    
    public class func suspend() {
        currentTask!.yield()
    }
}


public func async(_ queue: dispatch_queue_t = mainQueue, body: Void -> Void) -> Task<Void> {
    let task = Task(queue: queue, body: body)
    task.schedule()
    return task
}

public func async<T>(_ queue: dispatch_queue_t = mainQueue, body: Void -> T) -> Task<T> {
    let task = Task(queue: queue, body: body)
    task.schedule()
    return task
}

public func asyncFunc<ArgsType>(_ queue: dispatch_queue_t = mainQueue, fn: ArgsType -> Void) (_ args: ArgsType) -> Task<Void> {
    return async(queue, { fn(args) })
}

public func asyncFunc<ArgsType, ReturnType>(_ queue: dispatch_queue_t = mainQueue, fn: ArgsType -> ReturnType) (_ args: ArgsType) -> Task<ReturnType> {
    return async(queue, { fn(args) })
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