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
    
    func getPositions(address: String, walletId: String) async throws -> PerpetualPositionsSummary {
        let response = try await hyperCoreService.getPositions(user: address)
        
        return PerpetualPositionsSummary(
            positions: response.mapToPerpetualPositions(walletId: walletId),
            balance: try response.mapToPerpetualBalance()
        )
    }
    
    func getCandlesticks(symbol: String, period: ChartPeriod) async throws -> [ChartCandleStick] {
        let interval = hyperliquidInterval(for: period)
        let endTime = Int(Date().timeIntervalSince1970)
        let startTime = endTime - (interval.hours * 60 * 60)
        
        return try await hyperCoreService.getCandlesticks(
            coin: symbol,
            interval: interval.name,
            startTime: startTime * 1000,
            endTime: endTime * 1000
        )
        .compactMap { $0.toCandlestick() }
    }
    
    private func hyperliquidInterval(for period: ChartPeriod) -> (name: String, hours: Int) {
        switch period {
        case .hour: ("1m", 1)
        case .day: ("30m", 24)
        case .week: ("4h", 7 * 24)
        case .month: ("12h", 30 * 24)
        case .year: ("1w", 365 * 24)
        case .all: ("1M", 365 * 5 * 24)
        }
    }
    
    func getPerpetualsData() async throws -> [PerpetualData] {
        let metadata = try await hyperCoreService.getMetadata()
        
        return zip(metadata.universe.universe, metadata.assetMetadata).enumerated().compactMap { index, pair in
            let (universeAsset, assetMetadata) = pair
            guard let perpetual = assetMetadata.mapToPerpetual(
                      symbol: universeAsset.name,
                      maxLeverage: universeAsset.maxLeverage,
                      index: index
                  ) else { return .none }
            
            let assetId = mapHypercoreCoinToAssetId(universeAsset.name)
            let asset = universeAsset.asset(assetId: assetId)
            
            return PerpetualData(perpetual: perpetual, asset: asset, metadata: PerpetualMetadata(isPinned: false))
        }
    }
}
extension HypercoreUniverseAsset {
    func asset(assetId: AssetId) -> Asset {
        return Asset(
            id: assetId,
            name: "\(name)-USD",
            symbol: name,
            decimals: Int32(szDecimals),
            type: .perpetual
        )
    }
}
