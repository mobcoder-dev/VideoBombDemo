
import Foundation

/// A Future represents the outcome of an asynchronous operation
/// The outcome will be represented as an instance of the `Result` enum and will be stored
/// in the `result` property. As long as the operation is not yet completed, `result` will be nil.
/// Interested parties can be informed of the completion by using one of the available callback
/// registration methods (e.g. onComplete, onSuccess & onFailure) or by immediately composing/chaining
/// subsequent actions (e.g. map, flatMap, recover, andThen, etc.).
///
/// For more info, see the project README.md
public final class Future<T, E: Error>: Async<Result<T, E>> {
    
    public typealias CompletionCallback = (_ result: Result<T,E>) -> Void
    public typealias SuccessCallback = (T) -> Void
    public typealias FailureCallback = (E) -> Void
    
    public required init() {
        super.init()
    }
    
    public required init(result: Future.Value) {
        super.init(result: result)
    }
    
    public init(value: T, delay: DispatchTimeInterval) {
        super.init(result: .success(value), delay: delay)
    }
    
    public required init<A: AsyncType>(other: A) where A.Value == Value {
        super.init(other: other)
    }
    
    public required init(result: Value, delay: DispatchTimeInterval) {
        super.init(result: result, delay: delay)
    }
    
    public convenience init(value: T) {
        self.init(result: .success(value))
    }
    
    public convenience init(error: E) {
        self.init(result: .failure(error))
    }
    
    public required init(resolver: (_ result: @escaping (Value) -> Void) -> Void) {
        super.init(resolver: resolver)
    }
    
}

public func materialize<T, E>(_ scope: ((T?, E?) -> Void) -> Void) -> Future<T, E> {
    return Future { complete in
        scope { val, err in
            if let val = val {
                complete(.success(val))
            } else if let err = err {
                complete(.failure(err))
            }
        }
    }
}

public func materialize<T>(_ scope: ((T) -> Void) -> Void) -> Future<T, Never> {
    return Future { complete in
        scope { val in
            complete(.success(val))
        }
    }
}

public func materialize<E>(_ scope: ((E?) -> Void) -> Void) -> Future<Void, E> {
    return Future { complete in
        scope { err in
            if let err = err {
                complete(.failure(err))
            } else {
                complete(.success(()))
            }
        }
    }
}

/// Short-hand for `lhs.recover(rhs())`
/// `rhs` is executed according to the default threading model (see README.md)
public func ?? <T, E>(_ lhs: Future<T, E>, rhs: @autoclosure @escaping  () -> T) -> Future<T, Never> {
    return lhs.recover(context: DefaultThreadingModel(), task: { _ in
        return rhs()
    })
}

/// Short-hand for `lhs.recoverWith(rhs())`
/// `rhs` is executed according to the default threading model (see README.md)
public func ?? <T, E, E1>(_ lhs: Future<T, E>, rhs: @autoclosure @escaping () -> Future<T, E1>) -> Future<T, E1> {
    return lhs.recoverWith(context: DefaultThreadingModel(), task: { _ in
        return rhs()
    })
}

/// Can be used as the value type of a `Future` or `Result` to indicate it can never be a success.
/// This is guaranteed by the type system, because `NoValue` has no possible values and thus cannot be created.
public enum NoValue { }
