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
        lastPromise <- value
    }
}

extension PromiseSequence: SequenceType {
    public func generate() -> PromiseSequenceGenerator<T> {
        return PromiseSequenceGenerator(promise)
    }
}


private class RecurringPromise<T>: Promise<T?> {
    lazy private var next = RecurringPromise<T>()
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