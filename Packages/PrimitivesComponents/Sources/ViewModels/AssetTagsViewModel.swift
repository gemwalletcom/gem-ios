// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AssetTagsViewModel {
    public let tags: [AssetTag]
    public var selectedTag: AssetTag?
    
    public init(tags: [AssetTag]) {
        self.tags = tags
    }
    
    public var items: [AssetTagViewModel] {
        tags.map { AssetTagViewModel(tag: $0, isSelected: selectedTag == $0) }
    }
    
    public var query: String {
        selectedTag?.rawValue ?? .empty
    }
    
    public var hasSelected: Bool {
        selectedTag != nil
    }

    public mutating func setSelectedTag(_ tag: AssetTag?) {
        selectedTag = selectedTag == tag ? nil : tag
    }
}

public extension AssetTagsViewModel {
    static func `default`() -> AssetTagsViewModel {
        AssetTagsViewModel(tags: [.stablecoins, .trending])
    }
}
