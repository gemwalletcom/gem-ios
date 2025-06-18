// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Formatters

final class MnemonicFormatterTests {

    let wordsArray = ["test", "test2"]
    let wordsString = "test test2"

    @Test
    func testFromArray() {
        #expect(MnemonicFormatter.fromArray(words:wordsArray) == wordsString)
    }

    @Test
    func testToArray() {
        #expect(MnemonicFormatter.toArray(string: wordsString) == wordsArray)
        #expect(MnemonicFormatter.toArray(string: "test\n") == ["test"])
    }
}
