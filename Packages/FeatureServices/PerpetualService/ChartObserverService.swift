// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public actor ChartObserverService: ChartStreamable {
    private var continuation: AsyncStream<ChartCandleUpdate>.Continuation?

    public init() {}

    public func makeStream() -> AsyncStream<ChartCandleUpdate> {
        continuation?.finish()
        let (stream, newContinuation) = AsyncStream.makeStream(of: ChartCandleUpdate.self)
        continuation = newContinuation
        return stream
    }

    public func yield(_ update: ChartCandleUpdate) {
        continuation?.yield(update)
    }
}
