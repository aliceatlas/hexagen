  /*****\\\\
 /       \\\\    Hexagen/Swift/Coroutine.swift
/  /\ /\  \\\\   Part of Hexagen
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public func coroFunc <InType, OutType, ArgsType> (fn: ArgsType -> (OutType -> InType) -> Void) (_ args: ArgsType) -> AsymmetricCoroutine<InType, OutType> {
    return AsymmetricCoroutine(fn(args))
}

public class AsymmetricCoroutine <InType, OutType> {
    private var wrapper: AsymmetricCoroutineWrapper!
    
    private var nextIn: InType?
    private var nextOut: OutType?
    
    private var _started = false
    private var _completed = false
    
    public var started: Bool { return _started }
    public var completed: Bool { return _completed }
    public var running: Bool { return _started && !_completed }
    
    public init(_ fn: (OutType -> InType) -> Void) {
        wrapper = AsymmetricCoroutineWrapper { [unowned self] (exit) in
            exit()
            self._started = true
            fn { [unowned self] in
                self.nextOut = $0
                exit()
                
                let val = self.nextIn
                self.nextIn = nil
                return val!
            }
            self._completed = true
        }
    }
    
    public func start() -> OutType? {
        if _started {
            fatalError("can't call start() twice on the same coroutine")
        }
        return next()
    }
    
    public func send(val: InType) -> OutType? {
        if !_started {
            fatalError("must call start() before using send()")
        }
        nextIn = val
        return next()
    }
    
    private func next() -> OutType? {
        if _completed {
            fatalError("can't enter a coroutine that has completed")
        }
        wrapper.enter()
        
        let out = nextOut
        nextOut = nil
        
        return out
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