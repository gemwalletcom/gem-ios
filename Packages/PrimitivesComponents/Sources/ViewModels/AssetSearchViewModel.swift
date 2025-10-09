// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AssetSearchViewModel {
    public enum Focus {
        case search
        case tags
    }

    public var tagsViewModel: AssetTagsViewModel
    public var searchableQuery: String = .empty
    public var focus: Focus = .search

    public init(selectType: SelectAssetType) {
        tagsViewModel = AssetTagsViewModel(selectType: selectType)
    }

    public var priorityAssetsQuery: String? {
        switch focus {
        case .search: searchableQuery
        case .tags: tagsViewModel.query
        }
    }
}
