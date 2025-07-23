// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol PerpetualProvidable: Sendable {
    func provider() -> PerpetualProvider
    func getPositions(wallet: Wallet) async throws -> [PerpetualPosition]
    func getMarkets() async throws -> [Perpetual]
    func getCandlesticks(coin: String, startTime: Int, endTime: Int, interval: String) async throws -> [ChartCandleStick]
}
