  /*****\\\\
 /       \\\\    Swift/Generator.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class Gen<OutType>: Coro<Void, OutType>, SequenceType, GeneratorType {
    override public init(_ fn: (OutType -> Void) -> Void) {
        super.init(fn)
    }
    
    public func generate() -> Gen {
        return self
    }
    
    public func next() -> OutType? {
        return _started ? send(()) : start()
    }
}