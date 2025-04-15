import Foundation
import Primitives
import Style
import Localization
import ManageWalletService
import enum Keystore.KeystoreImportType

class ImportWalletViewModel: ObservableObject {

    let type: ImportWalletType
    let manageWalletService: ManageWalletService
    let wordSuggestor = WordSuggestor()
    let onFinishImport: (() -> Void)?

    @Published var buttonState = StateButtonStyle.State.normal

    init(
        type: ImportWalletType,
        manageWalletService: ManageWalletService,
        onFinishImport: (() -> Void)?
    ) {
        self.type = type
        self.manageWalletService = manageWalletService
        self.onFinishImport = onFinishImport
    }
    
    var title: String {
        switch type {
        case .multicoin: Localized.Wallet.multicoin
        case .chain(let chain): Asset(chain).name
        }
    }
    
    var name: String {
        WalletNameGenerator(type: type, manageWalletService: manageWalletService).name
    }
    
    var chain: Chain? {
        switch type {
        case .multicoin: .none
        case .chain(let chain): chain
        }
    }
    
    var showImportTypes: Bool {
        importTypes.count > 1
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
        try manageWalletService.import(name: name, type: keystoreType)
        onFinishImport?()
    }
    
    func wordSuggestionCalculate(value: String) -> String? {
        wordSuggestor.wordSuggestionCalculate(value: value)
    }
    
    func selectWordCalculate(input: String, word: String) -> String {
        wordSuggestor.selectWordCalculate(input: input, word: word)
    }
}
