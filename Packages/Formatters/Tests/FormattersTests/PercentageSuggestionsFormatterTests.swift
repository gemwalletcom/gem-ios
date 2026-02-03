// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Formatters

struct PercentageSuggestionsFormatterTests {

    let formatter = PercentageSuggestionsFormatter()

    @Test
    func suggestions() {
        #expect(formatter.suggestions(for: 0.28) == [5, 10, 15])
        #expect(formatter.suggestions(for: 3.90) == [5, 10, 15])
        #expect(formatter.suggestions(for: 767.0) == [3, 6, 9])
        #expect(formatter.suggestions(for: 78151.0) == [2, 4, 6])
    }
}
