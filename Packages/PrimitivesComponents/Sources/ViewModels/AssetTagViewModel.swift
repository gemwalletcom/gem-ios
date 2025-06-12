// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives
import Style
import Components
import SwiftUI

public struct AssetTagViewModel: TagItemViewable {
    public let tag: AssetTagSelection
    public let isSelected: Bool

    public init(tag: AssetTagSelection, isSelected: Bool) {
        self.tag = tag
        self.isSelected = isSelected
    }

    public var id: String { tag.id }

    public var title: String {
        switch tag {
        case .all: Localized.Common.all
        case let .tag(type):
            switch type {
            case .trending,
                    .trendingFiatPurchase:
                Localized.Assets.Tags.trending
            case .gainers: Localized.Assets.Tags.gainers
            case .losers: Localized.Assets.Tags.losers
            case .new: Localized.Assets.Tags.new
            case .stablecoins: Localized.Assets.Tags.stablecoins
            }
        }
    }
    public var image: Image? {
        // TODO: - integrate colorful images when available
        nil
    }
}
