//
//  NSOperationQueue+BrightFutures.swift
//  BrightFutures
//


import Foundation

public extension OperationQueue {
    /// An execution context that operates on the receiver.
    /// Tasks added to the execution context are executed as operations on the queue.
    var context: ExecutionContext {
        return { [weak self] task in
            self?.addOperation(BlockOperation(block: task))
        }
    }
}
