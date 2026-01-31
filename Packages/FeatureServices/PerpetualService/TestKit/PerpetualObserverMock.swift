// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@testable import PerpetualService

public actor PerpetualObserverMock: PerpetualObservable {
    public let chartService: any ChartStreamable = ChartObserverService()

    public private(set) var isConnected: Bool = false

    public init() {}

    public func connect(for wallet: Wallet) async {
        isConnected = true
    }

    public func disconnect() async {
        isConnected = false
    }

    public func subscribe(_ subscription: HyperliquidSubscription) async throws {}
    public func unsubscribe(_ subscription: HyperliquidSubscription) async throws {}
}
