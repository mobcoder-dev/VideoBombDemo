
import Foundation

/// The source of a future. Create a `Promise` when you are
/// performing an asynchronous task and want to return a future.
/// Return the future and keep the promise around to complete it
/// when the asynchronous operation is completed. Completing a 
/// promise is thread safe and is typically performed from the 
/// (background) thread where the operation itself is also performed.
public final class Promise<T, E: Error> {

    /// The future that will complete through this promise
    public let future: Future<T, E>
    
    /// Creates a new promise with a pending future
    public init() {
        self.future = Future<T, E>()
    }
    
    /// Completes the promise's future with the given future
    public func completeWith(_ other: Future<T, E>) {
        future.completeWith(other)
    }
    
    /// Completes the promise's future with the given success value
    /// See `Future.success(value: T)`
    public func success(_ value: T) {
        future.success(value)
    }
    
    /// Attempts to complete the promise's future with the given success value
    /// See `future.trySuccess(value: T)`
    @discardableResult
    public func trySuccess(_ value: T) -> Bool {
        return future.trySuccess(value)
    }
    
    /// Completes the promise's future with the given error
    /// See `future.failure(error: E)`
    public func failure(_ error: E) {
        future.failure(error)
    }

    /// Attempts to complete the promise's future with the given error
    /// See `future.tryFailure(error: E)`
    @discardableResult
    public func tryFailure(_ error: E) -> Bool {
        return future.tryFailure(error)
    }

    /// Completes the promise's future with the given result
    /// See `future.complete(result: Result<T, E>)`
    public func complete(_ result: Result<T, E>) {
        future.complete(result)
    }
    
    /// Attempts to complete the promise's future with the given result
    /// See `future.tryComplete(result: Result<T, E>)`
    @discardableResult
    public func tryComplete(_ result: Result<T,E>) -> Bool {
        return future.tryComplete(result)
    }
    
}
