// Copyright (c). Gem Wallet. All rights reserved.

import Store
import Primitives
import Localization
import PrimitivesComponents
import SwiftUI
import Style
import Components

public struct AssetsFilterViewModel: Sendable, Equatable {
    private let type: SelectAssetType
    var chainsFilter: ChainsFilterViewModel
    var hasBalance: Bool = false

    public init(type: SelectAssetType, model: ChainsFilterViewModel) {
        self.type = type
        self.chainsFilter = model
    }

    public var isAnyFilterSpecified: Bool { chainsFilter.isAnySelected || hasBalance }

    var filters: [AssetsRequestFilter] {
        guard isAnyFilterSpecified else { return defaultFilters }

        var result = defaultFilters

        if chainsFilter.isAnySelected {
            result.append(.chains(chainsFilter.selectedChains.map(\.rawValue)))
        }

        if hasBalance && showHasBalanceToggle {
            result.append(.hasBalance)
        }

        return result.unique()
    }

    public var defaultFilters: [AssetsRequestFilter] {
        switch type {
        case .send: [.enabled, .hasBalance]
        case .receive(let type):
            switch type {
            case .asset: [.enabled]
            case .collection: [.enabled, .chainsOrAssets([], Chain.allCases.filter { $0.isNFTSupported }.map { $0.rawValue})]
            }
        case .buy: [.enabled, .buyable]
        case .swap(let type):
            switch type {
            case .pay: [.enabled, .swappable, .hasBalance]
            case .receive(let chains, let assetIds):
                [
                    .enabled,
                    .chainsOrAssets(
                        chains.map { $0.rawValue },
                        assetIds.map { $0.identifier }
                    ),
                    .swappable,
                ]
            }
        case .manage: [.enabled]
        case .priceAlert: [.enabled, .priceAlerts]
        case .deposit: [ .chainsOrAssets([], [AssetId(chain: .arbitrum, tokenId: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831").identifier])]
        case .withdraw: [ .chainsOrAssets([], [Asset.hypercoreUSDC().id.identifier])]
        }
    }

    var showHasBalanceToggle: Bool {
        switch type {
        case .send, .receive, .buy, .swap, .priceAlert, .deposit, .withdraw: false
        case .manage: true
        }
    }

    var title: String { Localized.Filter.title }
    var clear: String { Localized.Filter.clear }
    var done: String { Localized.Common.done }

    var hasBalanceImageStyle: ListItemImageStyle? { .settings(assetImage: .image(Images.Filters.balance)) }
    var hasBalanceTitle: String { Localized.Filter.hasBalance }

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
