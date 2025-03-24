// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PrimitivesComponents

struct SelectAssetSearchViewModel {
    enum Focus {
        case search
        case tags
    }

    var tagsViewModel: AssetTagsViewModel = .default()
    var searchableQuery: String = .empty
    var focus: Focus = .search

    var priorityAssetsQuery: String? {
        switch focus {
        case .search: searchableQuery
        case .tags: tagsViewModel.query
        }
    }
}
