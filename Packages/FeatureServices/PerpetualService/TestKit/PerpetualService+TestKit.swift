// Copyright (c). Gem Wallet. All rights reserved.

import PerpetualService
import Primitives
import Store
import StoreTestKit

public extension PerpetualService {
    static func mock(
        store: PerpetualStore = .mock(),
        assetStore: AssetStore = .mock(),
        priceStore: PriceStore = .mock(),
        balanceStore: BalanceStore = .mock(),
        provider: PerpetualProvidable = PerpetualProviderMock()
    ) -> PerpetualService {
        PerpetualService(
            store: store,
            assetStore: assetStore,
            priceStore: priceStore,
            balanceStore: balanceStore,
            provider: provider
        )
    }
}

public struct PerpetualProviderMock: PerpetualProvidable {
    public init() {}

    public func provider() -> PerpetualProvider {
        .hypercore
    }

    public func getPositions(address: String) async throws -> PerpetualPositionsSummary {
        PerpetualPositionsSummary(
            positions: [],
            balance: PerpetualBalance(available: 0, reserved: 0, withdrawable: 0)
        )
    }

    public func getPerpetualsData() async throws -> [PerpetualData] {
        []
    }

    public func getCandlesticks(symbol: String, period: ChartPeriod) async throws -> [ChartCandleStick] {
        []
    }
}
