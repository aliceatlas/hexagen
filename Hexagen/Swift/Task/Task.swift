  /*****\\\\
 /       \\\\    Hexagen/Swift/Task/Task.swift
/  /\ /\  \\\\   Part of Hexagen
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class Task {
    private let queue: dispatch_queue_t
    private var coro: SimpleGenerator<Void>!
    private var yield: (Void -> Void)!
    
    private var completionPromise = Promise<Void>()
    
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
        coro = SimpleGenerator { [unowned self] yield in
            self.yield = yield
            body()
            self.completionPromise <- ()
        }
        schedule()
    }
    
    public convenience init(_ body: Void -> Void) {
        self.init(queue: dispatch_get_main_queue(), body: body)
    }
    
    internal func schedule() {
        dispatch_async(queue, enter)
    }
    
    private func enter() {
        //should only be called as a GCD block
        self.dynamicType.currentTask = self
        coro.next()
        self.dynamicType.currentTask = nil
    }
}

extension Task: Awaitable {
    public func await() {
        <-completionPromise
    }
}

public extension Task /* current task control */ {
    public class func suspend() {
        currentTask!.yield()
    }
}