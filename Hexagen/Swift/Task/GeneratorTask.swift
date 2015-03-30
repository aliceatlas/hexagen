  /*****\\\\
 /       \\\\    Swift/Task/GeneratorTask.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public final class AsyncGen<OutType, ReturnType>: Async<ReturnType> {
    private let promiseSequence: PromiseSequence<OutType> = PromiseSequence<OutType>()
    
    public init(queue: dispatch_queue_t = mainQueue, body: (OutType -> Void) -> ReturnType) {
        super.init(queue: queue, start: false, body: { [promiseSequence] in
            let ret = body { promiseSequence <- $0 }
            promiseSequence <- nil
            return ret
        })
    }
}

extension AsyncGen: SequenceType {
    public func generate() -> PromiseSequenceGenerator<OutType> {
        let gen = promiseSequence.generate()
        if !started {
            start()
        }
        return gen
    }
    
    public func map<T>(fn: OutType -> T) -> _MapWrapper<AsyncGen, T> {
        return _MapWrapper(self, fn)
    }
    
    public func filter(fn: OutType -> Bool) -> _FilterWrapper<AsyncGen> {
        return _FilterWrapper(self, fn)
    }
}

/* workaround for compiler crash when trying to directly use LazySequence constructs in map/filter above */

public class _SeqWrapper<T: SequenceType>: SequenceType {
    typealias Inner = LazySequence<T>
    let inner: Inner
    
    private init(_inner: Inner) {
        inner = _inner
    }
    
    public func generate() -> Inner.Generator {
        return inner.generate()
    }
    
    public func map<U>(fn: T.Generator.Element -> U) -> LazySequence<MapSequenceView<T, U>> {
        return inner.map(fn)
    }
    
    public func filter(fn: T.Generator.Element -> Bool) -> LazySequence<FilterSequenceView<T>> {
        return inner.filter(fn)
    }
}

public class _MapWrapper<Seq: SequenceType, Element>: _SeqWrapper<MapSequenceView<Seq, Element>> {
    private init(_ sequence: Seq, _ fn: Seq.Generator.Element -> Element) {
        super.init(_inner: lazy(sequence).map(fn))
    }
}

public class _FilterWrapper<Seq: SequenceType>: _SeqWrapper<FilterSequenceView<Seq>> {
    private init(_ sequence: Seq, _ fn: Seq.Generator.Element -> Bool) {
        super.init(_inner: lazy(sequence).filter(fn))
    }
}