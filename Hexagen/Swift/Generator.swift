  /*****\\\\
 /       \\\\    Swift/Generator.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public func genFunc<ArgsType, OutType>(fn: ArgsType -> (OutType -> Void) -> Void) (_ args: ArgsType) -> SimpleGenerator<OutType> {
    return SimpleGenerator(fn(args))
}

public class SimpleGenerator<OutType>: SequenceType, GeneratorType {
    private var coroutine: AsymmetricCoroutine<Void, OutType>
    
    public init(_ fn: (OutType -> Void) -> Void) {
        coroutine = AsymmetricCoroutine(fn)
    }
    
    public func generate() -> SimpleGenerator {
        return self
    }
    
    public func next() -> OutType? {
        if coroutine.started {
            return coroutine.send(())
        }
        return coroutine.start()
    }
}