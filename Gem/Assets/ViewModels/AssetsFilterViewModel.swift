// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import Settings

enum CainsFilterType: ChipSelectable {
    case allChains
    case chain(name: String)
    case chains(selected: [String])

    static var primary: CainsFilterType = .allChains

    var title: String {
        switch self {
        case .allChains:
            "All chains"
        case let .chain(name):
            name
        case let .chains(selected):
            "\(selected.count) chains"
        }
    }
}

struct AssetsFilterViewModel {
    var assetsRequest: AssetsRequest

    var allChains: [String] = AssetConfiguration.allChains.map({ $0.rawValue })
    var chainFilterType: CainsFilterType = .allChains

    init(wallet: Wallet, type: SelectAssetType) {
        let filterChains = wallet.type == .multicoin ? [] : [wallet.accounts.first?.chain].compactMap { $0?.rawValue }

        self.assetsRequest = AssetsRequest(
            walletID: wallet.id,
            filters: Self.defaultFilters(type: type)
        )
        // TODO: - integrate chains & filters selection
    }

    static func defaultFilters(type: SelectAssetType) -> [AssetsRequestFilter] {
        switch type {
        case .send: [.hasBalance]
        case .receive: [.includeNewAssets]
        case .buy: [.buyable, .includeNewAssets]
        case .swap: [.swappable]
        case .stake: [.stakeable]
        case .manage: [.includeNewAssets]
        case .hidden: [.hidden]
        }
    }

    /*
     public enum AssetsRequestFilter {
         case search(String)
         case hasBalance
         case hasFiatValue
         case buyable // available to buy
         case swappable
         case stakeable
         case enabled
         case hidden
         case chains([String])

         // special case
         case includeNewAssets
     }

     extension AssetsRequestFilter: Equatable {}

     */
}
