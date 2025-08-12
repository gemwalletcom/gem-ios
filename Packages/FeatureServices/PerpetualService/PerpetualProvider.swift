// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol PerpetualProvidable: Sendable {
    func provider() -> PerpetualProvider
    func getPositions(address: String) async throws -> PerpetualPositionsSummary
    func getPerpetualsData() async throws -> [PerpetualData]
    func getCandlesticks(symbol: String, period: ChartPeriod) async throws -> [ChartCandleStick]
}
