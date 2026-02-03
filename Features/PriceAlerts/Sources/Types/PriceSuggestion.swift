// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PrimitivesComponents

struct PriceSuggestion: SuggestionViewable {
    let title: String
    let value: String

    var inputValue: String { value }
    var id: String { title + value }
}
