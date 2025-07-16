// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Store
import ExplorerService
import Style
import Preferences
import PrimitivesComponents
import Formatters

public struct AssetDetailsInfoViewModel {
    
    private let priceData: PriceData
    private let explorerService: ExplorerService
    private let currencyFormatter: CurrencyFormatter

    public var showMarketValues: Bool { !marketValues.isEmpty }

    public init(
        priceData: PriceData,
        explorerService: ExplorerService = .standard,
        currencyFormatter: CurrencyFormatter = CurrencyFormatter(type: .abbreviated, currencyCode: Preferences.standard.currency)
        
    ) {
        self.priceData = priceData
        self.explorerService = explorerService
        self.currencyFormatter = currencyFormatter
    }
    
    public var marketCapViewModel: MarketValueViewModel {
        if let rank = priceData.market?.marketCapRank, Int(rank).isBetween(1, and: 1000) {
            return MarketValueViewModel(
                title: Localized.Asset.marketCap,
                subtitle: marketCapText,
                titleTag: " #\(rank) ",
                titleTagStyle: TextStyle(
                    font: .system(.body),
                    color: Colors.grayLight,
                    background: Colors.grayVeryLight
                )
            )
        }
        return MarketValueViewModel(title: Localized.Asset.marketCap, subtitle: marketCapText)
    }
    
    public var marketValues: [MarketValueViewModel] {
        return [
            marketCapViewModel,
            MarketValueViewModel(title: Localized.Asset.circulatingSupply, subtitle: circulatingSupplyText),
            MarketValueViewModel(title: Localized.Asset.totalSupply, subtitle: totalSupplyText),
            MarketValueViewModel(title: Localized.Asset.contract, subtitle: contractText, value: contract, url: contractUrl),
        ].filter { $0.subtitle?.isEmpty == false }
    }
    
    public var marketCapText: String? {
        if let marketCap = priceData.market?.marketCap {
            return currencyFormatter.string(marketCap)
        }
        return .none
    }

    public var circulatingSupplyText: String?  {
        if let circulatingSupply = priceData.market?.circulatingSupply {
            return currencyFormatter.string(double: circulatingSupply, symbol: priceData.asset.symbol)
        }
        return .none
    }

    public var totalSupplyText: String? {
        if let totalSupply = priceData.market?.totalSupply {
            return currencyFormatter.string(double: totalSupply, symbol: priceData.asset.symbol)
        }
        return .none
    }
    
    public var contract: String? {
        try? priceData.asset.getTokenId()
    }
    
    public var contractText: String? {
        guard let contract else { return .none }
        return AddressFormatter(address: contract, chain: priceData.asset.chain).value()
    }
    
    public var contractUrl: URL? {
        guard let contract else { return .none }
        return explorerService.tokenUrl(chain: priceData.asset.chain, address: contract)?.url
    }
    
    public var showLinks: Bool {
        !priceData.links.isEmpty
    }
    
    public var linksViewModel: SocialLinksViewModel {
        return SocialLinksViewModel(assetLinks: priceData.links)
    }
}
