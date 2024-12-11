// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension FeePriority: Identifiable {
    public var id: String { rawValue }

    public var rank: Int {
        switch self {
        case .slow: 3
        case .normal: 2
        case .fast: 1
        }
    }
}
