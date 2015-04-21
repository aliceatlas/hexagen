  /*****\\\\
 /       \\\\    Swift/Coroutine.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class Coro <InType, OutType> {
    private var wrapper: UnsafeMutablePointer<coro_ctx> = nil
    
    internal var _started = false
    private var _completed = false
    
    public var started: Bool { return _started }
    public var completed: Bool { return _completed }
    public var running: Bool { return _started && !_completed }
    
    public init(_ body: (OutType -> InType) -> Void) {
        wrapper = ctx_create(64*1024) { [yield] _ in
            body(yield)
        }
    }
    
    private func yield(val: OutType) -> InType {
        var _val = val
        let ret = ctx_yield(wrapper, &_val)
        return UnsafeMutablePointer<InType>(ret).memory
    }
    
    public func start() -> OutType? {
        if _started {
            fatalError("can't call start() twice on the same coroutine")
        }
        _started = true
        return enter(nil)
    }
    
    public func send(val: InType) -> OutType? {
        if !_started {
            fatalError("must call start() before using send()")
        }
        return enter(val)
    }
    
    private func enter(val: InType?) -> OutType? {
        if _completed {
            fatalError("can't enter a coroutine that has completed")
        }
        var out: UnsafeMutablePointer<Void> = nil
        if var bort = val {
            _completed = !ctx_enter(wrapper, &bort, &out)
        } else {
            _completed = !ctx_enter(wrapper, nil, &out)
        }
        
        if _completed {
            return nil
        }
        return UnsafeMutablePointer<OutType>(out).memory
    }
    
    public func forceClose() {
        _completed = true
    }
    
    deinit {
        if !_completed {
            fatalError("trying to deallocate a coroutine that has not completed; will probably leak memory. call forceClose() to allow this")
        }
    }
}