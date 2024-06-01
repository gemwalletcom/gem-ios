import Foundation
import WalletCore
import Primitives

public struct Mnemonic {
    
    public static func isValidWord(_ word: String) -> Bool {
        return WalletCore.Mnemonic.isValidWord(word: word)
    }
    
    public static func isValidWords(_ words: [String]) -> Bool {
        return WalletCore.Mnemonic.isValid(mnemonic: MnemonicFormatter.fromArray(words: words))
    }
}
