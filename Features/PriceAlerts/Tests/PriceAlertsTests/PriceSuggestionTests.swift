// Copyright (c). Gem Wallet. All rights reserved.

import Testing

@testable import PriceAlerts

struct PriceSuggestionTests {

    @Test
    func inputValue() {
        #expect(PriceSuggestion(title: "", value: 67000.0).inputValue == "67000")
        #expect(PriceSuggestion(title: "", value: 0.3).inputValue == "0.3")
    }
}
