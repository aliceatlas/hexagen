  /*****\\\\
 /       \\\\    Swift/Task/PromiseSequence.swift
/  /\ /\  \\\\   (part of Hexagen)
\  \_X_/  ////
 \       ////    Copyright © 2015 Alice Atlas (see LICENSE.md)
  \*****////


public class PromiseSequence<T> {
    private var promise: RecurringPromise<T>? = RecurringPromise<T>()
}

extension PromiseSequence: SendAwaitable {
    public func _awaitSend(value: T?) {
        let lastPromise = promise!
        promise = value != nil ? lastPromise.next : nil
        lastPromise._fulfill(value)
    }
}

extension PromiseSequence: SequenceType {
    public func generate() -> PromiseSequenceGenerator<T> {
        return PromiseSequenceGenerator(promise)
    }
    
    public func map<U>(fn: T -> U) -> LazySequence<MapSequenceView<PromiseSequence, U>> {
        return lazy(self).map(fn)
    }
    
    public func filter(fn: T -> Bool) -> LazySequence<FilterSequenceView<PromiseSequence>> {
        return lazy(self).filter(fn)
    }
}


private class RecurringPromise<T>: Promise<T?> {
    lazy private var next = RecurringPromise<T>()
    
    private override init() {
        super.init()
    }
}


public class PromiseSequenceGenerator<T>: GeneratorType, SequenceType {
    private var promise: RecurringPromise<T>?
    
    private init(_ promise: RecurringPromise<T>?) {
        self.promise = promise
    }
    
    public func generate() -> Self {
        return self
    }
    
    public func next() -> T? {
        if let promise = promise {
            let value = <-promise
            self.promise = value != nil ? promise.next : nil
            return value
        }
        return nil
    }
}