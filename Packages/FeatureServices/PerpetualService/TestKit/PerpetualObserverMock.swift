// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@testable import PerpetualService

public actor PerpetualObserverMock: PerpetualObservable {
    public let chartService: any ChartStreamable = ChartObserverService()

    public init() {}

    public func connect(for wallet: Wallet) async {}
    public func disconnect() async {}
    public func subscribe(_ subscription: HyperliquidSubscription) async throws {}
    public func unsubscribe(_ subscription: HyperliquidSubscription) async throws {}
}
