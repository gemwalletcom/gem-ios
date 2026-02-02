// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct PercentageSuggestion: SuggestionViewable {
    public let id: Int
    public let value: Int

    public var title: String { "\(value)%" }

    public init(value: Int) {
        self.id = value
        self.value = value
    }
}
