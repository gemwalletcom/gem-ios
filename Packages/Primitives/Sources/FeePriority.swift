// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum FeePriority: String, CaseIterable, Identifiable, Hashable {
    case slow
    case normal
    case fast

    public var id: String { rawValue }
}
