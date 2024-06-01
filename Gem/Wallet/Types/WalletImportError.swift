import Foundation

enum WalletImportError: LocalizedError {
    case emptyName //TODO: Remove this case, auto generate name
    case invalidSecretPhrase
    case invalidSecretPhraseWord(word: String)
    case invalidAddress
    
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Empty Name"
        case .invalidSecretPhrase:
            return Localized.Errors.Import.invalidSecretPhrase
        case .invalidSecretPhraseWord(let word):
            return Localized.Errors.Import.invalidSecretPhraseWord(word)
        case .invalidAddress:
            return Localized.Errors.invalidAddressName
        }
    }
}
