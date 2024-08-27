// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives

struct AssetsFilterViewModel {
    var assetsRequest: AssetsRequest

    init(wallet: Wallet, type: SelectAssetType) {
        let filterChains = wallet.type == .multicoin ? [] : [wallet.accounts.first?.chain].compactMap { $0?.rawValue }

        self.assetsRequest =  AssetsRequest(
            walletID: wallet.id,
            chains: filterChains,
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
}
