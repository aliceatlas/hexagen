  /*****\\\\
 /       \\\\    Swift/Task/GeneratorTask.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public func asyncGen<OutType>(_ queue: dispatch_queue_t = mainQueue, body: (OutType -> Void) -> Void) -> GeneratorTask<OutType, Void> {
    let task = GeneratorTask(queue: queue, body: body)
    return task
}

public func asyncGen<OutType, ReturnType>(_ queue: dispatch_queue_t = mainQueue, body: (OutType -> Void) -> ReturnType) -> GeneratorTask<OutType, ReturnType> {
    let task = GeneratorTask(queue: queue, body: body)
    return task
}

public func asyncGenFunc<ArgsType, OutType>(_ queue: dispatch_queue_t = mainQueue, fn: ArgsType -> (OutType -> Void) -> Void) (_ args: ArgsType) -> GeneratorTask<OutType, Void> {
    return asyncGen(queue, fn(args))
}

public func asyncGenFunc<ArgsType, OutType, ReturnType>(_ queue: dispatch_queue_t = mainQueue, fn: ArgsType -> (OutType -> Void) -> ReturnType) (_ args: ArgsType) -> GeneratorTask<OutType, ReturnType> {
    return asyncGen(queue, fn(args))
}

public class GeneratorTask<OutType, ReturnType>: Task<ReturnType> {
    private let promiseSequence: PromiseSequence<OutType> = PromiseSequence<OutType>()
    private var started = false
    
    public init(queue: dispatch_queue_t = mainQueue, body: (OutType -> Void) -> ReturnType) {
        super.init(queue: queue, body: { [promiseSequence] in
            let ret = body { promiseSequence <- $0 }
            promiseSequence <- nil
            return ret
        })
    }
}

extension GeneratorTask: SequenceType {
    public func generate() -> _GenWrapper<PromiseSequence<OutType>> {
        let gen = _GenWrapper(promiseSequence)
        if !started {
            schedule()
        }
        return gen
    }
    
    public func map<T>(fn: OutType -> T) -> _MapWrapper<GeneratorTask, T> {
        return _MapWrapper(self, fn)
    }
    
    public func filter(fn: OutType -> Bool) -> _FilterWrapper<GeneratorTask> {
        return _FilterWrapper(self, fn)
    }
}

/* workaround for unexplained compiler crash when trying to use PromiseSequenceGenerator here directly */

public class _GenWrapper<T: SequenceType where T.Generator: AnyObject>: GeneratorType {
    let inner: T.Generator
    
    private init(_ sequence: T) {
        inner = sequence.generate()
    }
    
    public func next() -> T.Generator.Element? {
        return inner.next()
    }
}

/* likewise with the LazySequence constructs */

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