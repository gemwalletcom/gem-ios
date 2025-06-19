// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension FeePriority {
    public init(_ gem: GemFeePriority) {
        switch gem {
        case .slow: self = .slow
        case .normal: self = .normal
        case .fast: self = .fast
        }
    }
}

extension GemFeePriority {
    public init(_ fee: FeePriority) {
        switch fee {
        case .slow: self = .slow
        case .normal: self = .normal
        case .fast: self = .fast
        }
    }
}
