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

extension FeePriority {
    public init(id: String) throws {
        if let priority = FeePriority(rawValue: id) {
            self = priority
        } else {
            throw AnyError("invalid priority: \(id)")
        }
    }
}
