// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import PriceService
import AssetsService

@Observable
public final class MarketsViewModel: Sendable  {
    
    //public var state: StateViewType<Markets> = .noData
    
    let service: MarketService
    let assetsService: AssetsService
    
    public init(
        service: MarketService,
        assetsService: AssetsService
    ) {
        self.service = service
        self.assetsService = assetsService
    }
    
    func fetch() async  {
        do {
            let markets = try await service.getMarkets()
            let assets = [markets.assets.gainers, markets.assets.losers, markets.assets.trending]
                .flatMap { $0 }
                .compactMap {
                    try? AssetId(id: $0)
                }
            try await assetsService.prefetchAssets(assetIds: assets)
            
        } catch {
            NSLog("get markets error: \(error)")
        }
    }
    
    var title: String {
        "Markets"
    }
}
