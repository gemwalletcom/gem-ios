// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemEarnProvider: CaseIterable {
    public static var allCases: [GemEarnProvider] {
        [.yo]
    }

    public var name: String {
        switch self {
        case .yo: "yo"
        }
    }

    public var displayName: String {
        switch self {
        case .yo: "Yo"
        }
    }

    public func map() -> EarnProvider {
        switch self {
        case .yo: .yo
        }
    }
}

extension EarnProvider {
    public func map() -> GemEarnProvider {
        switch self {
        case .yo: .yo
        }
    }
}
