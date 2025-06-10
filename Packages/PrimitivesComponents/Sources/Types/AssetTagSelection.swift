// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public enum AssetTagSelection: Hashable, Identifiable, Sendable {
    case all
    case tag(AssetTag)

    public var id: String {
        switch self {
        case .all: "all";
        case let .tag(tag): tag.rawValue
        }
    }
}

public extension AssetTagSelection {
    var tag: AssetTag? {
        switch self {
        case .all: nil
        case let .tag(tag): tag
        }
    }
}
