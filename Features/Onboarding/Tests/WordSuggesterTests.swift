// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing

@testable import Onboarding

struct WordSuggesterTests {
    @Test
    func testSuggestPartial() {
        let suggester = WordSuggester()
        let result = suggester.wordSuggestionCalculate(value: "ab")
        #expect(result.isNotEmpty)
    }

    @Test
    func testEmptyWhenEndsWithSpace() {
        let suggester = WordSuggester()
        let result = suggester.wordSuggestionCalculate(value: "ab ")
        #expect(result.isEmpty)
    }

    @Test
    func testExactMatchReturnsEmpty() {
        let suggester = WordSuggester()
        let word = "abandon"
        let result = suggester.wordSuggestionCalculate(value: word)
        #expect(result.isEmpty)
    }

    @Test
    func testReplaceLastWord() {
        let suggester = WordSuggester()
        let input = "abando"
        let word = "abandon"
        let result = suggester.selectWordCalculate(input: input, word: word)
        #expect(result == "abandon ")
    }
}
