  /*****\\\\
 /       \\\\    Swift/Coroutine.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class Coro <InType, OutType> {
    internal var context: UnsafeMutablePointer<coro_ctx> = nil
    
    internal(set) public var started = false
    internal(set) public var completed = false
    
    public var running: Bool { return started && !completed }
    
    public init(_ body: (OutType -> InType) -> Void) {
        context = ctx_create(64*1024) { [yield] _ in
            body(yield)
        }
    }
    
    private func yield(val: OutType) -> InType {
        var _val = val
        let ret = ctx_yield(context, &_val)
        return UnsafeMutablePointer<InType>(ret).memory
    }
    
    public func start() -> OutType? {
        if started {
            fatalError("can't call start() twice on the same coroutine")
        }
        started = true
        if completed {
            fatalError("can't enter a coroutine that has completed")
        }
        var out: UnsafeMutablePointer<Void> = nil
        if !ctx_enter(context, nil, &out) {
            completed = true
            return nil
        }
        return UnsafeMutablePointer<OutType>(out).memory
    }
    
    public func send(val: InType) -> OutType? {
        if !started {
            fatalError("must call start() before using send()")
        }
        if completed {
            fatalError("can't enter a coroutine that has completed")
        }
        var out: UnsafeMutablePointer<Void> = nil
        var _val = val
        if !ctx_enter(context, &_val, &out) {
            completed = true
            return nil
        }
        return UnsafeMutablePointer<OutType>(out).memory
    }
    
    public func forceClose() {
        completed = true
    }
    
    deinit {
        if !completed {
            fatalError("trying to deallocate a coroutine that has not completed; will probably leak memory. call forceClose() to allow this")
        }
        ctx_destroy(context)
    }
}