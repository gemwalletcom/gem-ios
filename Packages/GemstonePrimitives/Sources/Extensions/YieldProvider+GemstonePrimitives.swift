// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemYieldProvider {
    public var displayName: String {
        switch self {
        case .yo: "Yo"
        }
    }

    public func map() -> YieldProvider {
        switch self {
        case .yo: .yo
        }
    }
}

extension YieldProvider {
    public func map() -> GemYieldProvider {
        switch self {
        case .yo: .yo
        }
    }
}
