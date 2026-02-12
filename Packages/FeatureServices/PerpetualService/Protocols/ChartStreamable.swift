// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol ChartStreamable: Actor {
    func makeStream() -> AsyncStream<ChartCandleUpdate>
    func yield(_ update: ChartCandleUpdate)
}
