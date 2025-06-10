// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUICore
import Style

public struct AssetTagsViewModel {
    public let selectType: SelectAssetType
    public var selectedTag: AssetTag?
    
    public init(selectType: SelectAssetType) {
        self.selectType = selectType
    }
    
    public var tags: [AssetTag] {
        switch selectType {
        case .receive(let type):
            switch type {
            case .asset: [.stablecoins]
            case .collection: []
            }
        case .manage,
            .priceAlert,
            .swap: [.trending, .stablecoins]
        case .buy: [.trendingFiatPurchase, .stablecoins]
        case .send: [.stablecoins]
        }
    }
    
    public var items: [AssetTagViewModel] {
        [AssetTagViewModel(tag: nil, isSelected: selectedTag == nil)] + tags.map { AssetTagViewModel(tag: $0, isSelected: selectedTag == $0) }
    }
    
    public var query: String? {
        selectedTag?.rawValue
    }
    
    public var hasSelected: Bool {
        selectedTag != nil
    }

    public mutating func setSelectedTag(_ tag: AssetTag?) {
        selectedTag = selectedTag == tag ? nil : tag
    }
}
