import Foundation
import Primitives
import Style
import Localization
import WalletService
import NameService
import PrimitivesComponents
import SwiftUI
import Components
import enum Keystore.KeystoreImportType
import struct Keystore.Mnemonic

@Observable
@MainActor
final class ImportWalletViewModel {
    private let walletService: WalletService
    private let wordSuggester = WordSuggester()
    private let nameService: any NameServiceable

    let type: ImportWalletType

    var name: String
    var input: String = ""
    var wordsSuggestion: [String] = []
    var importType: WalletImportType = .phrase
    var nameResolveState: NameRecordState = .none
    var buttonState = ButtonState.normal

    var isPresentingScanner = false
    var isPresentingAlertMessage: AlertMessage?

    private let onFinish: (() -> Void)?

    init(
        walletService: WalletService,
        nameService: any NameServiceable,
        type: ImportWalletType,
        onFinish: (() -> Void)?
    ) {
        self.walletService = walletService
        self.nameService = nameService
        self.type = type
        self.name = WalletNameGenerator(type: type, walletService: walletService).name
        self.onFinish = onFinish
    }

    var title: String {
        switch type {
        case .multicoin: Localized.Wallet.multicoin
        case .chain(let chain): Asset(chain).name
        }
    }

    var walletFieldTitle: String { Localized.Wallet.name }

    var pasteButtonTitle: String { Localized.Common.paste }
    var pasteButtonImage: Image { Images.System.paste }

    var qrButtonTitle: String { Localized.Wallet.scan }
    var qrButtonImage: Image { Images.System.qrCodeViewfinder }

    var alertTitle: String { Localized.Errors.validation("") }

    var chain: Chain? {
        switch type {
        case .multicoin: .none
        case .chain(let chain): chain
        }
    }
    
    var nameRecordViewModel: NameRecordViewModel? {
        guard let chain else { return nil }
        return NameRecordViewModel(chain: chain, nameService: nameService)
    }

    var showImportTypes: Bool { importTypes.count > 1 }
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

    var footerText: AttributedString? {
        switch importType {
        case .phrase, .privateKey: .none
        case .address: try? AttributedString(markdown: Localized.Wallet.importAddressWarning)
        }
    }
}

// MARK: - Business Logic

extension ImportWalletViewModel {

    func onChangeImportType(_: WalletImportType, _: WalletImportType) {
        input = ""
    }

    func onChangeInput(_: String, newValue: String) {
        wordsSuggestion = wordSuggester.wordSuggestionCalculate(value: newValue)
    }

    func onSelectActionButton() {
        buttonState = .loading(showProgress: true)

        Task {
            do {
                try await importWallet()
            } catch {
                isPresentingAlertMessage = AlertMessage(
                    title: alertTitle,
                    message: error.localizedDescription
                )
                buttonState = .normal
            }
        }
    }

    func onSelectScanQR() {
        isPresentingScanner = true
    }

    func onHandleScan(_ result: String) {
        input = result
    }

    func onSelectWord(_ word: String) {
        input = wordSuggester.selectWordCalculate(
            input: input,
            word: word
        )
    }

    func onPaste() {
        guard let string = UIPasteboard.general.string else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        input = string.trim()
    }
}

// MARK: - Private

extension ImportWalletViewModel {
    private func importWallet() async throws {
        let recipient: RecipientImport = {
            if let result = nameResolveState.result {
                return RecipientImport(name: result.name, address: result.address)
            }
            return RecipientImport(name: name, address: input)
        }()
        switch importType {
        case .phrase:
            let words = input.split(separator: " ").map{String($0)}
            guard try validateForm(type: importType, address: recipient.address, words: words) else {
                return
            }
            switch type {
            case .multicoin:
                try await importWallet(
                    name: recipient.name,
                    keystoreType: .phrase(words: words, chains: AssetConfiguration.allChains)
                )
            case .chain(let chain):
                try await importWallet(
                    name: recipient.name,
                    keystoreType: .single(words: words, chain: chain)
                )
            }
        case .privateKey:
            guard try validateForm(type: importType, address: recipient.address, words: [input]) else {
                return
            }
            try await importWallet(name: recipient.name, keystoreType: .privateKey(text: input, chain: chain!))
        case .address:
            guard try validateForm(type: importType, address: recipient.address, words: []) else {
                return
            }
            let chain = chain!
            let address = chain.checksumAddress(recipient.address)

            try await importWallet(name: recipient.name, keystoreType: .address(chain: chain, address: address))
        }
    }

    private func importWallet(name: String, keystoreType: KeystoreImportType) async throws {
        try await walletService.importWallet(name: name, type: keystoreType)
        onFinish?()
    }

    private func validateForm(type: WalletImportType, address: String, words: [String]) throws  -> Bool {
        guard !name.isEmpty else {
            throw WalletImportError.emptyName
        }
        switch type {
        case .phrase:
            for word in words {
                if !Mnemonic.isValidWord(word) {
                    throw WalletImportError.invalidSecretPhraseWord(word: word)
                }
            }
            guard Mnemonic.isValidWords(words) else {
                throw WalletImportError.invalidSecretPhrase
            }
        case .privateKey:
            return !words.joined().isEmpty
        case .address:
            guard chain!.isValidAddress(address) else {
                throw WalletImportError.invalidAddress
            }
        }
        return true
    }
}
