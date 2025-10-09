// Copyright (c). Gem Wallet. All rights reserved.

@preconcurrency import Combine

extension AnyPublisher where Failure == Never, Output: Sendable {
    func asAsyncStream() -> AsyncStream<Output> {
        AsyncStream { continuation in
            let cancellable = self.sink(
                receiveCompletion: { completion in
                    if case .finished = completion {
                        continuation.finish()
                    }
                },
                receiveValue: { value in
                    continuation.yield(value)
                }
            )
            continuation.onTermination = { _ in cancellable.cancel() }
        }
    }
}
