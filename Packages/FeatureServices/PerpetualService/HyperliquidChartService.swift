// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public actor HyperliquidChartService: Sendable {
    private var continuation: AsyncStream<ChartCandleStick>.Continuation?

    public init() {}

    public func makeStream() -> AsyncStream<ChartCandleStick> {
        continuation?.finish()
        let (stream, newContinuation) = AsyncStream.makeStream(of: ChartCandleStick.self)
        continuation = newContinuation
        return stream
    }

    func yield(_ candle: ChartCandleStick) {
        continuation?.yield(candle)
    }
}
