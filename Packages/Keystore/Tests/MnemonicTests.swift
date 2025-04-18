import Testing
@testable import Keystore

final class MnemonicTests {
    let validWords = [
        "credit",
        "expect",
        "life",
        "fade",
        "cover",
        "suit",
        "response",
        "wash",
        "pear",
        "what",
        "skull",
        "force"
    ]

    let invalidWords = [
        "ripple",
        "scissors",
        "hisc",
        "mammal",
        "hire",
        "column",
        "oak",
        "again",
        "sun",
        "offer",
        "wealth",
        "tomorrow"
    ]

    @Test
    func testIsValidMnemonicWords() {
        #expect(Mnemonic.isValidWords(validWords))
        #expect(!Mnemonic.isValidWords(invalidWords))
    }

    @Test
    func testIsValidMnemonicWord() {
        #expect(Mnemonic.isValidWord(validWords.first!))
        #expect(!Mnemonic.isValidWord("test1"))
    }
}
