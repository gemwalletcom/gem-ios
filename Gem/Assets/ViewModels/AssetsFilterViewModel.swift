// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import Settings

struct AssetsFilterViewModel {
    private let type: SelectAssetType
    var assetsRequest: AssetsRequest
    let allChains: [Chain] = AssetConfiguration.allChains

    var selectedChains: [Chain] {
        get {
            assetsRequest.filters
                .flatMap { $0.associatedChains }
                .compactMap{ Chain(rawValue: $0) }
        }
        set {
            assetsRequest.filters.removeAll { $0.associatedChains.count > 0 }
            let rawValues = newValue.map { $0.rawValue }
            assetsRequest.filters.append(.chains(rawValues))
        }
    }

    init(wallet: Wallet, type: SelectAssetType) {
        self.assetsRequest = AssetsRequest(
            walletID: wallet.id,
            filters: Self.defaultFilters(type: type)
        )
        self.type = type
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

    var isCusomFilteringSpecified: Bool {
        switch type {
        case .send, .receive, .buy, .swap, .stake, .hidden: false
        case .manage: !selectedChains.isEmpty
        }
    }

    var chainsFilterModel: ChainsFilterViewModel {
        ChainsFilterViewModel(
            type: ChainsFilterType(selectedChains: selectedChains)
        )
    }
    
    var title: String { Localized.Filter.title }
    var clear: String { Localized.Filter.clear }
}

// MARK: - Models extensions

extension AssetsRequestFilter {
    var associatedChains: [String] {
        if case let .chains(chains) = self {
            return chains
        }
        return []
    }
}
