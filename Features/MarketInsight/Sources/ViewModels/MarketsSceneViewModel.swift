// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import PriceService
import AssetsService
import PrimitivesComponents

@MainActor
@Observable
public final class MarketsSceneViewModel: Sendable  {
    
    var state: StateViewType<MarketsViewModel> = .noData
    
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
        state = .loading
        do {
            let markets = try await service.getMarkets()
            let assets = [markets.assets.gainers, markets.assets.losers, markets.assets.trending]
                .flatMap { $0 }
                .compactMap { try? AssetId(id: $0) }
            
            try await assetsService.prefetchAssets(assetIds: assets)
            
            self.state = .data(MarketsViewModel(markets: markets))
        } catch {
            self.state = .error(error)
            NSLog("get markets error: \(error)")
        }
    }
    
    var title: String {
        "Markets"
    }
    
    var emptyContentModel: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .markets)
    }
}
