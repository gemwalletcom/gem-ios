// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives
import Style
import SwiftUI

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
        case .trending,
                .trendingFiatPurchase: Localized.Assets.Tags.trending
        case .gainers: Localized.Assets.Tags.gainers
        case .losers: Localized.Assets.Tags.losers
        case .new: Localized.Assets.Tags.new
        case .stablecoins: Localized.Assets.Tags.stablecoins
        }
    }

    public var image: Image? {
        switch tag {
        case .trending,
                .trendingFiatPurchase: isSelected ? Images.System.trending : Images.System.trendingFill
        case .stablecoins: isSelected ? Images.System.t : Images.System.tFill
        case .gainers,
                .losers,
                .new: nil
        }
    }

    public var opacity: CGFloat { isSelected ? 1.0 : 0.5 }
}
