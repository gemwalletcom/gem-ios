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
    
    public var items: [AssetTagViewModel] {
        let tags: [AssetTag]
        switch selectType {
        case .manage, .priceAlert, .receive, .swap:
            tags = [.stablecoins, .trending]
        case .buy:
            tags = [.stablecoins, .trendingFiatPurchase]
        case .send:
            tags = [.stablecoins]
        }
        return tags.map { AssetTagViewModel(tag: $0, isSelected: selectedTag == $0) }
    }
    
    public var query: String? {
        selectedTag?.rawValue
    }
    
    public var hasSelected: Bool {
        selectedTag != nil
    }
    
    public func foregroundColor(for tag: AssetTag) -> Color {
        if tag == selectedTag {
            return .primary
        }
        return Colors.secondaryText
    }
    
    public func opacity(for tag: AssetTag) -> Double {
        !hasSelected || selectedTag == tag ? 1 : 0.35
    }

    public mutating func setSelectedTag(_ tag: AssetTag?) {
        selectedTag = selectedTag == tag ? nil : tag
    }
}
