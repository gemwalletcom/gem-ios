// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
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
        chainsFilter.isAnySelected
    }

    var defaultFilters: [AssetsRequestFilter] {
        switch type {
        case .send: [.hasBalance]
        case .receive(let type):
            switch type {
            case .asset: []
            case .collection: [.chainsOrAssets([], Chain.allCases.filter { $0.isNFTSupported }.map { $0.rawValue})]
            }
        case .buy: [.buyable]

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
                ]
            }
        case .manage: []
        case .priceAlert: [.priceAlerts]
        }
    }

    var title: String { Localized.Filter.title }
    var clear: String { Localized.Filter.clear }
    var done: String { Localized.Common.done }

    var networksModel: NetworkSelectorViewModel {
        NetworkSelectorViewModel(
            state: .data(.plain(chainsFilter.allChains)),
            selectedItems: chainsFilter.selectedChains,
            selectionType: .multiSelection
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
