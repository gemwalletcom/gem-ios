// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style

public struct AssetTagsViewModel {
    public let selectType: SelectAssetType
    public var selectedTag: AssetTagSelection

    public init(selectType: SelectAssetType, selectedTag: AssetTagSelection = .all) {
        self.selectType = selectType
        self.selectedTag = selectedTag
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
        [AssetTagViewModel(tag: .all, isSelected: selectedTag == .all)] + tags.map { AssetTagViewModel(tag: .tag($0), isSelected: selectedTag == .tag($0)) }
    }
    
    public var query: String? {
        switch selectedTag {
        case .all: nil
        case let .tag(assetTag):
            assetTag.rawValue
        }
    }
}
