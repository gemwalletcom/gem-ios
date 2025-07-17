// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public actor SerialExecutor {
    private var currentTask: Task<Void, Never>?
    
    public init() {}
    
    public func execute<T: Sendable>(_ operation: @escaping @Sendable () async throws -> T) async throws -> T {
        let previousTask = currentTask
        
        return try await withCheckedThrowingContinuation { continuation in
            currentTask = Task {
                await previousTask?.value
                
                do {
                    let result = try await operation()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func executeWithCancellation<T: Sendable>(_ operation: @escaping @Sendable () async throws -> T) async throws -> T {
        currentTask?.cancel()
        
        return try await withCheckedThrowingContinuation { continuation in
            currentTask = Task {
                guard !Task.isCancelled else {
                    continuation.resume(throwing: CancellationError())
                    return
                }
                
                do {
                    let result = try await operation()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
