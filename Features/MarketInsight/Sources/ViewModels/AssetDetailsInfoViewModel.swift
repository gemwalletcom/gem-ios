// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import ExplorerService
import Preferences
import PrimitivesComponents
import Formatters

struct AssetDetailsInfoViewModel {
    private let priceData: PriceData
    private let explorerService: ExplorerService
    private let market: AssetMarketViewModel?

    init(
        priceData: PriceData,
        explorerService: ExplorerService = .standard,
        currency: String = Preferences.standard.currency
    ) {
        self.priceData = priceData
        self.explorerService = explorerService
        self.market = priceData.market.map {
            AssetMarketViewModel(market: $0, assetSymbol: priceData.asset.symbol, currency: currency)
        }
    }

    var marketValues: [MarketValueViewModel] {
        guard let market else { return [contractViewModel].withValues() }
        return [contractViewModel, market.marketCap, market.tradingVolume, market.fdv].withValues()
    }

    var supplyValues: [MarketValueViewModel] {
        guard let market else { return [] }
        return [market.circulatingSupply, market.totalSupply, market.maxSupply].withValues()
    }

    var allTimeValues: [MarketValueViewModel] {
        guard let market else { return [] }
        return [market.allTimeHigh, market.allTimeLow].withValues()
    }

    var showLinks: Bool { !priceData.links.isEmpty }

    var linksViewModel: SocialLinksViewModel {
        SocialLinksViewModel(assetLinks: priceData.links)
    }

    // MARK: - Contract

    private var contractViewModel: MarketValueViewModel {
        MarketValueViewModel(
            title: Localized.Asset.contract,
            subtitle: contractText,
            value: contract,
            url: contractUrl
        )
    }

    private var contract: String? {
        try? priceData.asset.getTokenId()
    }

    private var contractText: String? {
        contract.map { AddressFormatter(address: $0, chain: priceData.asset.chain).value() }
    }

    private var contractUrl: URL? {
        contract.flatMap { explorerService.tokenUrl(chain: priceData.asset.chain, address: $0)?.url }
    }
}
