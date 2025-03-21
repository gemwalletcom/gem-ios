// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives

public struct AssetTagViewModel: Identifiable {
    public var id: String { tag.rawValue }

    public let tag: AssetTag
    public let isSelected: Bool
    
    public init(tag: AssetTag, isSelected: Bool) {
        self.tag = tag
        self.isSelected = isSelected
    }
    
    public var title: String {
        switch tag {
        case .trending: Localized.AssetTag.trending
        case .gainers: Localized.AssetTag.gainers
        case .losers: Localized.AssetTag.losers
        case .new: Localized.AssetTag.new
        case .stablecoins: Localized.AssetTag.stablecoins
        }
    }
}
