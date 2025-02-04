// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Gemstone
import Store
import ExplorerService
import Style
import Preferences
import PrimitivesComponents

public struct AssetDetailsInfoViewModel {
    
    private let priceData: PriceData
    private let explorerService: ExplorerService
    private let currencyFormatter: CurrencyFormatter

    public var showMarketValues: Bool { !marketValues.isEmpty }

    public init(
        priceData: PriceData,
        explorerService: ExplorerService = .standard,
        currencyFormatter: CurrencyFormatter = CurrencyFormatter(currencyCode: Preferences.standard.currency)
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
                    font: .system(.body, weight: .regular),
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
            return IntegerFormatter.standard.string(circulatingSupply, symbol: priceData.asset.symbol)
        }
        return .none
    }

    public var totalSupplyText: String? {
        if let totalSupply = priceData.market?.totalSupply {
            return IntegerFormatter.standard.string(totalSupply, symbol: priceData.asset.symbol)
        }
        return .none
    }
    
    public var contract: String? {
        guard let tokenId = try? priceData.asset.getTokenId() else {
            return .none
        }
        return tokenId
    }
    
    public var contractText: String? {
        guard let contract else { return .none }
        return AddressFormatter(address: contract, chain: priceData.asset.chain).value()
    }
    
    public var contractUrl: URL? {
        guard let contract else { return .none }
        return explorerService.tokenUrl(chain: priceData.asset.chain, address: contract)?.url
    }
    
    public var linksViewModel: SocialLinksViewModel? {
        guard priceData.links.isEmpty == false else { return .none }
        return SocialLinksViewModel(links: priceData.links)
    }
}
