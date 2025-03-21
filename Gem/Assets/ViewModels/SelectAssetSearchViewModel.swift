// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PrimitivesComponents

struct SelectAssetSearchViewModel {
    var tagsViewModel: AssetTagsViewModel = .default()
    
    var searchableQuery: String = .empty
    var priorityAssetsQuery: String {
        get { [searchableQuery, tagsViewModel.query].joined() }
    }
}
