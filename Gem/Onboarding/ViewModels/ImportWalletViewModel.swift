import Foundation
import Keystore
import Primitives
import Settings

struct ImportWalletViewModel {
    
    let type: ImportWalletType
    let keystore: any Keystore
    let wordSuggestor = WordSuggestor()

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
            return [.phrase, .address]
        }
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
