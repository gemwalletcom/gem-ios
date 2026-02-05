// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents

enum WalletSearchMode: Sendable {
    case initial
    case tagBrowsing
    case searching
}

struct WalletSearchModel {
    struct Limits {
        static let fetch = 100
        static let perpetuals = 3

        struct Assets {
            static let initial = 12
            static let tagBrowse = 18
            static let search = 25
        }
    }

    var assetSearch: AssetSearchViewModel

    var searchableQuery: String {
        get { assetSearch.searchableQuery }
        set { assetSearch.searchableQuery = newValue }
    }

    var tagsViewModel: AssetTagsViewModel {
        get { assetSearch.tagsViewModel }
        set { assetSearch.tagsViewModel = newValue }
    }

    var focus: AssetSearchViewModel.Focus {
        get { assetSearch.focus }
        set { assetSearch.focus = newValue }
    }

    init(selectType: SelectAssetType) {
        self.assetSearch = AssetSearchViewModel(selectType: selectType)
    }
}

// MARK: - Limits

extension WalletSearchModel {
    var perpetualsLimit: Int { Limits.perpetuals }

    static func initialFetchLimit(isPerpetualEnabled: Bool) -> Int {
        if isPerpetualEnabled {
            return Limits.Assets.initial + 1
        }
        return Limits.fetch
    }

    static func searchItemTypes(isPerpetualEnabled: Bool) -> [SearchItemType] {
        var types: [SearchItemType] = [.asset]
        if isPerpetualEnabled {
            types.append(.perpetual)
        }
        return types
    }

    static func recentActivityTypes(isPerpetualEnabled: Bool) -> [RecentActivityType] {
        if isPerpetualEnabled {
            return RecentActivityType.allCases
        }
        return RecentActivityType.allCases.filter { $0 != .perpetual }
    }

    func searchMode(tag: String?) -> WalletSearchMode {
        if assetSearch.searchableQuery.isNotEmpty { return .searching }
        if tag != nil { return .tagBrowsing }
        return .initial
    }

    func assetsLimit(tag: String?, isPerpetualEnabled: Bool) -> Int {
        guard isPerpetualEnabled else { return Limits.fetch }
        switch searchMode(tag: tag) {
        case .initial: return Limits.Assets.initial
        case .tagBrowsing: return Limits.Assets.tagBrowse
        case .searching: return Limits.Assets.search
        }
    }

    func fetchLimit(tag: String?, isPerpetualEnabled: Bool) -> Int {
        guard isPerpetualEnabled else { return Limits.fetch }
        switch searchMode(tag: tag) {
        case .initial, .tagBrowsing: return assetsLimit(tag: tag, isPerpetualEnabled: true) + 1
        case .searching: return Limits.fetch
        }
    }
}
