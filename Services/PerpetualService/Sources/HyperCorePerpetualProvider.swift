// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Blockchain

struct HyperCorePerpetualProvider: PerpetualProvidable {
    
    let hyperCoreService: HyperCoreService
    
    init(hyperCoreService: HyperCoreService) {
        self.hyperCoreService = hyperCoreService
    }
    
    func provider() -> PerpetualProvider {
        .hypercore
    }
    
    func getPositions(address: String, walletId: String) async throws -> [PerpetualPosition] {
        return try await hyperCoreService
            .getPositions(user: address)
            .mapToPerpetualPositions(walletId: walletId)
    }
    
    func getPerpetuals() async throws -> [Perpetual] {
        let metadata = try await hyperCoreService.getMetadata()
        
        return zip(metadata.universe.universe, metadata.assetMetadata).compactMap { universeAsset, assetMetadata in
            assetMetadata.mapToPerpetual(
                symbol: universeAsset.name,
                maxLeverage: universeAsset.maxLeverage
            )
        }
    }
    
    func getPerpetual(symbol: String) async throws -> Perpetual {
        let perpetuals = try await getPerpetuals()
        guard let perpetual = perpetuals.first(where: { $0.name == symbol }) else {
            throw PerpetualError.marketNotFound(symbol: symbol)
        }
        return perpetual
    }
    
    func getCandlesticks(symbol: String, period: ChartPeriod) async throws -> [ChartCandleStick] {
        let interval = hyperliquidInterval(for: period)
        let endTime = Int(Date().timeIntervalSince1970 * 1000)
        let startTime = endTime - (60 * interval.durationMs)
        
        return try await hyperCoreService.getCandlesticks(
            coin: symbol,
            interval: interval.name,
            startTime: startTime,
            endTime: endTime
        )
        .compactMap { $0.toCandlestick() }
    }
    
    private func hyperliquidInterval(for period: ChartPeriod) -> (name: String, durationMs: Int) {
        switch period {
        case .hour: ("1m", 60_000)
        case .day: ("5m", 300_000)
        case .week: ("1h", 3_600_000)
        case .month: ("4h", 14_400_000)
        case .year: ("1d", 86_400_000)
        case .all: ("1w", 604_800_000)
        }
    }
}
