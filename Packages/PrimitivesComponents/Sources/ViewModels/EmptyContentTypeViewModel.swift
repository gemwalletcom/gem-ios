// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components
import Localization

// TODO: - add localizations, add actions ( now they are empty ), review texts, review images
public struct EmptyContentTypeViewModel: EmptyContentViewable {
    public let type: EmptyContentType

    public init(type: EmptyContentType) {
        self.type = type
    }

    public var title: String {
        switch type {
        case .nfts: "Your NFTs will appear here️"
        case .priceAlerts: "Your alerts will appear here️"
        case .asset: "Your transactions will appear here️"
        case .activity: "Your activity will appear here"
        case .stake: "Your stakes will appear here"
        case .walletConnect: "Your connections will appear here️"
        case let .search(searchType, _):
            switch searchType {
            case .assets: "No assets found"
            case .networks: "No networks found"
            case .activity: "No activities found"
            }
        case .markets: "Your markets data will appear here"
        }
    }

    public var description: String? {
        switch type {
        case let .nfts(action): action != nil ? "Receive your first NFT" : nil
        case .priceAlerts: "Enable them by adding coins to track"
        case let .asset(ticker): "Receive, swap or buy \(ticker)"
        case .activity: "Make your first transacton"
        case let .stake(ticker): "Stake your first \(ticker)"
        case .walletConnect: "Scan or paste code to connect to the DApp"
        case let .search(searchType, action):
            switch searchType {
            case .assets: action != nil ? "You can try add it manually" : "Check the spelling or try a new search"
            case .networks: "Check the spelling or try a new search"
            case .activity: "Clear filters to refresh your activities"
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
