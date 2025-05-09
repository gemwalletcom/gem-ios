import Foundation
import Primitives
import Style
import Localization
import WalletService
import enum Keystore.KeystoreImportType

@MainActor
protocol ImportWalletViewModelNavigation {
    func importWalletOnNext()
}

class ImportWalletViewModel: ObservableObject {

    let type: ImportWalletType
    let walletService: WalletService
    let wordSuggestor = WordSuggestor()
    let navigation: ImportWalletViewModelNavigation

    @Published var buttonState = StateButtonStyle.State.normal

    init(
        type: ImportWalletType,
        walletService: WalletService,
        navigation: ImportWalletViewModelNavigation
    ) {
        self.type = type
        self.walletService = walletService
        self.navigation = navigation
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

    var keyEncodingTypes: [EncodingType] {
        chain?.keyEncodingTypes ?? []
    }

    var importPrivateKeyPlaceholder: String {
        keyEncodingTypes.map { $0.rawValue }.joined(separator: " / ")
    }

    func importWallet(name: String, keystoreType: KeystoreImportType) throws {
        try walletService.importWallet(name: name, type: keystoreType)
    }
    
    func wordSuggestionCalculate(value: String) -> String? {
        wordSuggestor.wordSuggestionCalculate(value: value)
    }
    
    func selectWordCalculate(input: String, word: String) -> String {
        wordSuggestor.selectWordCalculate(input: input, word: word)
    }
}

// MARK: - Navigation

@MainActor
extension ImportWalletViewModel {
    func onNext() {
        navigation.importWalletOnNext()
    }
}
