// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol PerpetualServiceable: Sendable {
    func getPositions(walletId: WalletId) async throws -> [PerpetualPosition]
    func getMarkets() async throws -> [Perpetual]
    func updatePositions(wallet: Wallet) async throws
    func updateMarkets() async throws
    func updateMarket(symbol: String) async throws
    func candlesticks(symbol: String, period: ChartPeriod) async throws -> [ChartCandleStick]
    func portfolio(wallet: Wallet) async throws -> PerpetualPortfolioChartData
    func setPinned(_ isPinned: Bool, perpetualId: String) throws
}
