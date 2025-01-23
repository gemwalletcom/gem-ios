// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components

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
            }
        }
    }

    public var description: String? {
        switch type {
        case .nfts: "Collect your first NFT"
        case .priceAlerts: "Enable them by adding coins to track"
        case let .asset(ticker): "Receive, swap or buy \(ticker)"
        case .activity: "Make your first transacton"
        case let .stake(ticker): "Stake your first \(ticker)"
        case .walletConnect: "Scan or paste code to connect to the DApp"
        case let .search(searchType, _):
            switch searchType {
            case .assets: "You can try add it manually"
            case .networks: "Check the spelling or try a new search"
            }
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
        }
    }

    public var buttons: [EmptyAction] {
        switch type {
        case .nfts, .priceAlerts, .asset, .stake, .walletConnect:
            return []
        case let .activity(receive, buy):
            let all = [
                EmptyAction(title: "Receive", action: receive),
                EmptyAction(title: "Buy", action: buy)
            ]
            return all.filter { $0.action != nil }
        case let .search(searchType, action):
            switch searchType {
            case .assets:
                let custom = EmptyAction(title: "Add Custom Token", action: action)
                return [custom].filter { $0.action != nil }
            case .networks:
                return []
            }
        }
    }
}
