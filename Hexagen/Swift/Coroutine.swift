  /*****\\\\
 /       \\\\    Swift/Coroutine.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class Coro <InType, OutType> {
    private var wrapper: UnsafePointer<Void> = alloc_asymm_coro()
    
    private var nextIn: UnsafeMutablePointer<InType> = UnsafeMutablePointer.alloc(1)
    private var nextOut: UnsafeMutablePointer<OutType> = UnsafeMutablePointer.alloc(1)
    
    internal var _started = false
    private var _completed = false
    
    public var started: Bool { return _started }
    public var completed: Bool { return _completed }
    public var running: Bool { return _started && !_completed }
    
    public init(_ fn: (OutType -> InType) -> Void) {
        setup_asymm_coro(wrapper) { [unowned self, nextOut, nextIn] (exit) in
            exit()
            self._started = true
            func yield(val: OutType) -> InType {
                nextOut.initialize(val)
                exit()
                return nextIn.move()
            }
            fn(yield)
            self._completed = true
        }
    }
    
    public func start() -> OutType? {
        if _started {
            fatalError("can't call start() twice on the same coroutine")
        }
        return enter()
    }
    
    public func send(val: InType) -> OutType? {
        if !_started {
            fatalError("must call start() before using send()")
        }
        nextIn.initialize(val)
        return enter()
    }
    
    private func enter() -> OutType? {
        if _completed {
            fatalError("can't enter a coroutine that has completed")
        }
        enter_asymm_coro(wrapper)
        
        if _completed {
            return nil
        }
        return nextOut.move()
    }
    
    public func forceClose() {
        _completed = true
    }
    
    deinit {
        if !_completed {
            fatalError("trying to deallocate a coroutine that has not completed; will probably leak memory. call forceClose() to allow this")
        }
        destroy_asymm_coro(wrapper)
        nextIn.dealloc(1)
        nextOut.dealloc(1)
    }
}