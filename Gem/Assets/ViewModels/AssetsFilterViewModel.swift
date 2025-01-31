// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import Settings
import Localization
import PrimitivesComponents

struct AssetsFilterViewModel {
    private let type: SelectAssetType
    var chainsFilter: ChainsFilterViewModel

    init(type: SelectAssetType, model: ChainsFilterViewModel) {
        self.type = type
        self.chainsFilter = model
    }

    var isAnyFilterSpecified: Bool {
        switch type {
        case .send, .receive, .buy, .swap, .priceAlert: false
        case .manage: chainsFilter.isAnySelected
        }
    }

    var defaultFilters: [AssetsRequestFilter] {
        switch type {
        case .send: [.hasBalance]
        case .receive(let type):
            switch type {
            case .asset: [.includeNewAssets]
            case .collection: [.chains(Chain.allCases.filter { $0.isNFTSupported }.map { $0.rawValue})]
            }
        case .buy: [.buyable, .includeNewAssets]

        case .swap(let type):
            switch type {
            case .pay: [.swappable, .hasBalance]
            case .receive(let chains, let assetIds):
                [
                    .chainsOrAssets(
                        chains.map { $0.rawValue },
                        assetIds.map { $0.identifier }
                    ),
                    .swappable,
                    .includeNewAssets,
                ]
            }
        case .manage: [.includeNewAssets]
        case .priceAlert: [.priceAlerts]
        }
    }

    var title: String { Localized.Filter.title }
    var clear: String { Localized.Filter.clear }
    var done: String { Localized.Common.done }

    var networksModel: NetworkSelectorViewModel {
        NetworkSelectorViewModel(
            items: chainsFilter.allChains,
            selectedItems: chainsFilter.selectedChains,
            isMultiSelectionEnabled: true
        )
    }
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
