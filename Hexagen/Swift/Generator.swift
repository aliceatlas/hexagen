  /*****\\\\
 /       \\\\    Hexagen/Swift/Generator.swift
/  /\ /\  \\\\   Part of Hexagen
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class SimpleGenerator <OutType> : SequenceType, GeneratorType {
    typealias Generator = SimpleGenerator<OutType>
    typealias Element = OutType
    
    private var coroutine: AsymmetricCoroutine<Void, OutType>
    
    public class func make <ArgsType> (fn: ArgsType -> (OutType -> Void) -> Void) (_ args: ArgsType) -> Self {
        return self(fn(args))
    }
    
    public required init(_ fn: (OutType -> Void) -> Void) {
        coroutine = AsymmetricCoroutine(fn)
    }
    
    public func generate() -> Generator {
        return self
    }
    
    public func next() -> Element? {
        if coroutine.started {
            return coroutine.send(())
        }
        return coroutine.start()
    }
}
