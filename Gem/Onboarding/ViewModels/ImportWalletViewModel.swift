import Foundation
import Keystore
import Primitives
import Settings
import Style

class ImportWalletViewModel: ObservableObject {

    let type: ImportWalletType
    let keystore: any Keystore
    let wordSuggestor = WordSuggestor()

    @Published var buttonState = StateButtonStyle.State.normal

    init(
        type: ImportWalletType,
        keystore: any Keystore
    ) {
        self.type = type
        self.keystore = keystore
    }
    
    var title: String {
        switch type {
        case .multicoin:
            return Localized.Wallet.multicoin
        case .chain(let chain):
            return Asset(chain).name
        }
    }
    
    var name: String {
        WalletNameGenerator(type: type, keystore: keystore).name
    }
    
    var chain: Chain? {
        switch type {
        case .multicoin:
            return .none
        case .chain(let chain):
            return chain
        }
    }
    
    var showImportTypes: Bool {
        return importTypes.count > 1
    }
    
    var importTypes: [WalletImportType] {
        switch type {
        case .multicoin:
            return [.phrase]
        case .chain:
            if chain?.keyEncodingTypes.isEmpty ?? true {
                return [.phrase, .address]
            }
            return [.phrase, .privateKey, .address]
        }
    }

    var keyEncodingTypes: [EncodingType] {
        chain?.keyEncodingTypes ?? []
    }

    var importPrivateKeyPlaceholder: String {
        keyEncodingTypes.map { $0.rawValue }.joined(separator: " / ")
    }

    func importWallet(name: String, keystoreType: KeystoreImportType) throws {
        try keystore.importWallet(name: name, type: keystoreType)
    }
    
    func wordSuggestionCalculate(value: String) -> String? {
        wordSuggestor.wordSuggestionCalculate(value: value)
    }
    
    func selectWordCalculate(input: String, word: String) -> String {
        wordSuggestor.selectWordCalculate(input: input, word: word)
    }
}
