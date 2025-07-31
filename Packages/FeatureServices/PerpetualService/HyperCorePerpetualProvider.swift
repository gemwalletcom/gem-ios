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
    
    func getPerpetualsData() async throws -> [PerpetualData] {
        let metadata = try await hyperCoreService.getMetadata()
        
        return zip(metadata.universe.universe, metadata.assetMetadata).compactMap { universeAsset, assetMetadata in
            guard let perpetual = assetMetadata.mapToPerpetual(
                      symbol: universeAsset.name,
                      maxLeverage: universeAsset.maxLeverage
                  ) else { return .none }
            
            let assetId = mapHypercoreCoinToAssetId(universeAsset.name)
            let asset = universeAsset.asset(assetId: assetId)
            
            return PerpetualData(perpetual: perpetual, asset: asset)
        }
    }
}
extension HypercoreUniverseAsset {
    func asset(assetId: AssetId) -> Asset {
        let name = "\(name)-USD"
        return Asset(
            id: assetId,
            name: name,
            symbol: name,
            decimals: Int32(szDecimals),
            type: .perpetual
        )
    }
}
