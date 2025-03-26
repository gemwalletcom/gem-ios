// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components
import Localization

// TODO: - integrate localization texts
public struct EmptyContentTypeViewModel: EmptyContentViewable {
    public let type: EmptyContentType

    public init(type: EmptyContentType) {
        self.type = type
    }

    public var title: String {
        switch type {
        case .nfts: Localized.Nft.State.Empty.title
        case .priceAlerts: Localized.PriceAlerts.State.Empty.title
        case .asset: Localized.Asset.State.Empty.title
        case .activity: Localized.Activity.State.Empty.title
        case .stake: Localized.Stake.State.Empty.title
        case .walletConnect: Localized.WalletConnect.State.Empty.title
        case .markets: Localized.Markets.State.Empty.title
        case let .search(searchType, _):
            switch searchType {
            case .assets: Localized.Assets.State.Empty.searchTitle
            case .networks: Localized.Networks.State.Empty.searchTitle
            case .activity: Localized.Activity.State.Empty.searchTitle
            }
        }
    }

    public var description: String? {
        switch type {
        case let .nfts(action): action != nil ? Localized.Nft.State.Empty.description : nil
        case .priceAlerts: Localized.PriceAlerts.State.Empty.description
        case let .asset(ticker): Localized.Asset.State.Empty.description(ticker)
        case .activity: Localized.Activity.State.Empty.description
        case let .stake(ticker): Localized.Stake.State.Empty.description(ticker)
        case .walletConnect: Localized.WalletConnect.State.Empty.description
        case let .search(searchType, action):
            switch searchType {
            case .assets: action != nil ? Localized.Assets.State.Empty.searchDescription : Localized.Search.State.Empty.description
            case .networks: Localized.Search.State.Empty.description
            case .activity: Localized.Activity.State.Empty.searchDescription
            }
        case .markets: .none
        }
    }

    public var image: Image? {
        switch type {
        case .nfts: Images.EmptyContent.nft
        case .priceAlerts: Images.EmptyContent.priceAlerts
        case .asset, .activity: Images.EmptyContent.activity
        case .stake: Images.EmptyContent.stake
        case .walletConnect: Images.EmptyContent.walletConnect
        case .search: Images.EmptyContent.search
        case .markets: Images.EmptyContent.activity
        }
    }

    public var buttons: [EmptyAction] {
        switch type {
        case .priceAlerts, .asset, .stake, .walletConnect, .markets:
            return []
        case let .nfts(action):
            let receive = EmptyAction(title: Localized.Wallet.receive, action: action)
            return [receive]
        case let .activity(receive, buy):
            let all = [
                EmptyAction(title: Localized.Wallet.receive, action: receive),
                EmptyAction(title: Localized.Wallet.buy, action: buy)
            ]
            return all.filter { $0.action != nil }
        case let .search(searchType, action):
            switch searchType {
            case .assets:
                let custom = EmptyAction(title: Localized.Assets.addCustomToken, action: action)
                return [custom].filter { $0.action != nil }
            case .networks:
                return []
            case .activity:
                let clean = EmptyAction(title: Localized.Filter.clear, action: action)
                return [clean]
            }
        }
    }
}
