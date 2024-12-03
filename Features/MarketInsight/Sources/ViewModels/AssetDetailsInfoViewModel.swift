// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Gemstone
import Store
import GemstonePrimitives

public struct AssetDetailsInfoViewModel {
    
    private let priceData: PriceData
    private let explorerStorage: ExplorerStorable
    private let currencyFormatter: CurrencyFormatter
    
    public var showLinksSection: Bool { !links.isEmpty }
    public var showMarketValues: Bool { !marketValues.isEmpty }
    
    public var linksSectionText: String { Localized.Social.links }

    public init(
        priceData: PriceData,
        explorerStorage: ExplorerStorable,
        currencyFormatter: CurrencyFormatter
    ) {
        self.priceData = priceData
        self.explorerStorage = explorerStorage
        self.currencyFormatter = currencyFormatter
    }
    
    private func communityLink(for value: String) -> SocialUrl? {
        switch value {
        case "x": .x
        case "discord": .discord
        case "reddit": .reddit
        case "telegram": .telegram
        case "youTube": .youTube
        case "facebook": .facebook
        case "website": .website
        case "coingecko": .coingecko
        default: .none
        }
    }
    
    public var links: [InsightLink] {
        return priceData.links.map {
            if let type = communityLink(for: $0.name),
               let url = URL(string: $0.url) {
                return CommunityLink(type: type, url: url)
            }
            return .none
        }
        .compactMap { $0 }
        .sorted()
        .map {
            InsightLink(
                title: $0.type.name,
                subtitle: $0.host,
                url: $0.url,
                image: $0.type.image
            )
        }
    }
    
    public var marketValues: [MarketValueViewModel] {
        return [
            MarketValueViewModel(title: Localized.Asset.marketCap, subtitle: marketCapText, value: .none, url: .none),
            MarketValueViewModel(title: Localized.Asset.circulatingSupply, subtitle: circulatingSupplyText, value: .none, url: .none),
            MarketValueViewModel(title: Localized.Asset.totalSupply, subtitle: totalSupplyText, value: .none, url: .none),
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
        return ExplorerService(storage: explorerStorage)
            .tokenUrl(chain: priceData.asset.chain, address: contract)?.url
    }
}