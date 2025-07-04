import Foundation
import Primitives
import Style
import Localization
import WalletService
import enum Keystore.KeystoreImportType

// TODO: - migrate to @observable macro
class ImportWalletViewModel: ObservableObject {

    let type: ImportWalletType
    let walletService: WalletService
    let wordSuggester = WordSuggester()
    let onFinish: (() -> Void)?

    @Published var buttonState = ButtonState.normal

    init(
        type: ImportWalletType,
        walletService: WalletService,
        onFinish: (() -> Void)?
    ) {
        self.type = type
        self.walletService = walletService
        self.onFinish = onFinish
    }
    
    var title: String {
        switch type {
        case .multicoin: Localized.Wallet.multicoin
        case .chain(let chain): Asset(chain).name
        }
    }
    
    var name: String {
        WalletNameGenerator(type: type, walletService: walletService).name
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
    
    func footerText(type: WalletImportType) -> AttributedString? {
        switch type {
        case .phrase, .privateKey: .none
        case .address: try? AttributedString(markdown: Localized.Wallet.importAddressWarning)
        }
    }

    var keyEncodingTypes: [EncodingType] {
        chain?.keyEncodingTypes ?? []
    }

    var importPrivateKeyPlaceholder: String {
        keyEncodingTypes.map { $0.rawValue }.joined(separator: " / ")
    }

    func importWallet(name: String, keystoreType: KeystoreImportType) throws {
        try walletService.importWallet(name: name, type: keystoreType)
        onFinish?()
    }
    
    func wordSuggestionCalculate(value: String) -> [String] {
        wordSuggester.wordSuggestionCalculate(value: value)
    }
    
    func selectWordCalculate(input: String, word: String) -> String {
        wordSuggester.selectWordCalculate(input: input, word: word)
    }
}
