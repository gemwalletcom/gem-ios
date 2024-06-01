import XCTest
import Keystore

final class MnemonicTests: XCTestCase {

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
        "force",
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
        "tomorrow",
    ]
    
    func testIsValidMnemonicWords() {
        XCTAssertTrue(Mnemonic.isValidWords(validWords))
        XCTAssertFalse(Mnemonic.isValidWords(invalidWords))
    }
    
    func testIsValidMnemonicWord() {
        XCTAssertTrue(Mnemonic.isValidWord(validWords.first!))
        XCTAssertFalse(Mnemonic.isValidWord("test1"))
    }
}
