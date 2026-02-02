// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone

extension GemYieldProvider: CaseIterable {
    public static var allCases: [GemYieldProvider] {
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
}
