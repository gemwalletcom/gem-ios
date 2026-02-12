// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PrimitivesComponents

struct PriceSuggestion: SuggestionViewable {
    let title: String
    let value: Double

    var inputValue: String {
        value.formatted(.number.grouping(.never))
    }
    var id: String { "\(title)_\(inputValue)" }
}
