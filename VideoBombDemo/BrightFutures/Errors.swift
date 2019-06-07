

import Foundation

/// An enum representing every possible error for errors returned by BrightFutures
/// A `BrightFuturesError` can also wrap an external error (e.g. coming from a user defined future)
/// in its `External` case. `BrightFuturesError` has the type of the external error as its generic parameter.
public enum BrightFuturesError<E: Error>: Error {
    
    /// Indicates that a matching element could not be found, e.g. while filtering or finding
    case noSuchElement
    
    /// Used in the implementation of InvalidationToken
    case invalidationTokenInvalidated
    
    /// Indicates that an invalid / unexpected state was reached. This error is used in places that should not be executed
    case illegalState
    
    /// Wraps a different ErrorType instance
    case external(E)

    /// Constructs a BrightFutures.External with the given external error
    public init(external: E) {
        self = .external(external)
    }
}

extension BrightFuturesError: Equatable where E: Equatable {
    /// Returns `true` if `left` and `right` are both of the same case ignoring .External associated value
    public static func ==(lhs: BrightFuturesError<E>, rhs: BrightFuturesError<E>) -> Bool {
        switch (lhs, rhs) {
        case (.noSuchElement, .noSuchElement): return true
        case (.invalidationTokenInvalidated, .invalidationTokenInvalidated): return true
        case (.external(let lhs), .external(let rhs)): return lhs == rhs
        default: return false
        }
    }
}
