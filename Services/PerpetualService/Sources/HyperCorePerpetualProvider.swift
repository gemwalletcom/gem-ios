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
    
    func getPositions(wallet: Wallet) async throws -> [PerpetualPosition] {
        guard let account = wallet.accounts.first(where: { 
            $0.chain == .arbitrum || $0.chain == .hyperCore
        }) else {
            return []
        }
        
        return try await hyperCoreService
            .getPositions(user: account.address)
            .mapToPerpetualPositions(walletId: wallet.id)
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
    
    func getCandlesticks(coin: String, startTime: Int, endTime: Int, interval: String) async throws -> [ChartCandleStick] {
        try await hyperCoreService.getCandlesticks(
            coin: coin,
            interval: interval,
            startTime: startTime,
            endTime: endTime
        )
        .compactMap { $0.toCandlestick() }
    }
}
