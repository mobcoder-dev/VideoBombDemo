import Foundation

/// The context in which something can be executed
/// By default, an execution context can be assumed to be asynchronous unless stated otherwise
public typealias ExecutionContext = (@escaping () -> Void) -> Void

/// Immediately executes the given task. No threading, no semaphores.
public let ImmediateExecutionContext: ExecutionContext = { task in
    task()
}

/// Runs immediately if on the main thread, otherwise asynchronously on the main thread
public let ImmediateOnMainExecutionContext: ExecutionContext = { task in
    if Thread.isMainThread {
        task()
    } else {
        DispatchQueue.main.async(execute: task)
    }
}

/// From https://github.com/BoltsFramework/Bolts-Swift/blob/5fe4df7acb384a93ad93e8595d42e2b431fdc266/Sources/BoltsSwift/Executor.swift#L56
public let MaxStackDepthExecutionContext: ExecutionContext = { task in
    struct Static {
        static let taskDepthKey = "com.bolts.TaskDepthKey"
        static let maxTaskDepth = 20
    }
    
    var localThreadDictionary = Thread.current.threadDictionary
    
    var previousDepth: Int
    if let depth = localThreadDictionary[Static.taskDepthKey] as? Int {
        previousDepth = depth
    } else {
        previousDepth = 0
    }
    
    if previousDepth > 20 {
        DispatchQueue.global().async(execute: task)
    } else {
        localThreadDictionary[Static.taskDepthKey] = previousDepth + 1
        task()
        localThreadDictionary[Static.taskDepthKey] = previousDepth
    }
}

public typealias ThreadingModel = () -> ExecutionContext

public var DefaultThreadingModel: ThreadingModel = defaultContext

/// Defines BrightFutures' default threading behavior:
/// - if on the main thread, `DispatchQueue.main.context` is returned
/// - if off the main thread, `DispatchQueue.global().context` is returned
public func defaultContext() -> ExecutionContext {
    return (Thread.isMainThread ? DispatchQueue.main : DispatchQueue.global()).context
}
