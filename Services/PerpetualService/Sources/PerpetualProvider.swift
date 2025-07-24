// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol PerpetualProvidable: Sendable {
    func provider() -> PerpetualProvider
    func getPositions(address: String, walletId: String) async throws -> [PerpetualPosition]
    func getPerpetuals() async throws -> [Perpetual]
    func getPerpetual(symbol: String) async throws -> Perpetual
    func getCandlesticks(symbol: String, period: ChartPeriod) async throws -> [ChartCandleStick]
}
