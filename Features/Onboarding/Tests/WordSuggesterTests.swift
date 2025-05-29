// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing

@testable import Onboarding

struct WordSuggesterTests {
    let suggester = WordSuggester()
    
    @Test
    func testSuggestPartial() {
        #expect(suggester.wordSuggestionCalculate(value: "ab").isNotEmpty)
    }

    @Test
    func testEmptyWhenEndsWithSpace() {
        #expect(suggester.wordSuggestionCalculate(value: "ab ").isEmpty)
    }

    @Test
    func testExactMatchReturnsEmpty() {
        #expect(suggester.wordSuggestionCalculate(value: "abandon").isEmpty)
    }

    @Test
    func testReplaceLastWord() {
        #expect(suggester.selectWordCalculate(input: "abando", word: "abandon") == "abandon ")
    }
}
