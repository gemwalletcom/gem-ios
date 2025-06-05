// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PrimitivesComponents
import Primitives

struct SelectAssetSearchViewModel {
    enum Focus {
        case search
        case tags
    }

    var tagsViewModel: AssetTagsViewModel
    var searchableQuery: String = .empty
    var focus: Focus = .search
    
    init(selectType: SelectAssetType) {
        tagsViewModel = AssetTagsViewModel(selectType: selectType)
    }

    var priorityAssetsQuery: String? {
        switch focus {
        case .search: searchableQuery
        case .tags: tagsViewModel.query
        }
    }
}
