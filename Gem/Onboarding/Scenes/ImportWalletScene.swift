import SwiftUI
import Keystore
import Primitives
import Style
import Components
import QRScanner
import Settings

struct ImportWalletScene: View {
    
    enum Field: Int, Hashable {
        case name, phrase, address, privateKey
    }
    @Environment(\.isWalletsPresented) private var isWalletsPresented
    
    @State private var name: String = ""
    @State private var wordSuggestion: String? = .none

    @State private var importType: WalletImportType = .address
    @State private var secretPhrase: String = ""
    @State private var privateKey: String = ""
    @State private var address: String = ""
    @State private var isPresentingErrorMessage: String?
    @State private var isPresentingScanner = false
    @FocusState private var focusedField: Field?
    @State var nameResolveState: NameRecordState = .none
    
    let model: ImportWalletViewModel
    
    init(
        model: ImportWalletViewModel
    ) {
        self.model = model
    }
    
    var body: some View {
        VStack {
            Form {
                Section {
                    FloatTextField(Localized.Wallet.name, text: $name)
                        .focused($focusedField, equals: .name)
                }
                Section {
                    VStack {
                        if model.showImportTypes {
                            Picker("", selection: $importType) {
                                ForEach(model.importTypes) { type in
                                    Text(type.title).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        switch importType {
                        case .phrase:
                            TextField(Localized.Wallet.Import.secretPhrase, text: $secretPhrase, axis: .vertical)
                                .textInputAutocapitalization(.never)
                                .lineLimit(8)
                                .keyboardType(.alphabet)
                                .autocorrectionDisabled(true)
                                .frame(minHeight: 80, alignment: .top)
                                .focused($focusedField, equals: .phrase)
                                .accessibilityIdentifier("phrase")
                                .toolbar {
                                    ToolbarItem(placement: .keyboard) {
                                        WordSuggestionView(word: $wordSuggestion, selectWord: selectWord)
                                    }
                                }
                                .padding(.top, Spacing.small)
                        case .privateKey:
                            if !model.keyEncodingTypes.isEmpty {
                                TextField(Localized.Wallet.Import.privateKey(model.importPrivateKeyPlaceholder), text: $privateKey, axis: .vertical)
                                    .textInputAutocapitalization(.never)
                                    .lineLimit(8)
                                    .keyboardType(.default)
                                    .autocorrectionDisabled(true)
                                    .frame(minHeight: 80, alignment: .top)
                                    .focused($focusedField, equals: .privateKey)
                                    .padding(.top, Spacing.small)
                            }
                        case .address:
                            if let chain = model.chain {
                                HStack {
                                    TextField(Localized.Wallet.Import.addressField, text: $address, axis: .vertical)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .focused($focusedField, equals: .address)
                                        .frame(minHeight: 80, alignment: .top)
                                        .accessibilityIdentifier("address")
                                        .padding(.top, Spacing.small)
                                    NameRecordView(
                                        model: NameRecordViewModel(chain: chain),
                                        state: $nameResolveState,
                                        address: $address
                                    )
                                }
                            }
                        }
                        HStack(alignment: .center, spacing: 16) {
                            ListButton(
                                title: Localized.Common.paste,
                                image: Image(systemName: SystemImage.paste),
                                action: paste
                            )
                            if model.type != .multicoin {
                                ListButton(
                                    title: Localized.Wallet.scan,
                                    image: Image(systemName: SystemImage.qrCode),
                                    action: scanQR
                                )
                            }
                        }
                    }
                    .listRowBackground(Colors.white)
                }
            }
            Spacer()
            Button(Localized.Wallet.Import.action) {
                Task {
                    do {
                        focusedField = nil
                        let _ = try importWallet()
                    } catch {
                        isPresentingErrorMessage = error.localizedDescription
                    }
                }
            }
            .accessibilityIdentifier("import_wallet")
            .frame(maxWidth: Spacing.scene.button.maxWidth)
            .buttonStyle(.blue())
        }
        .padding(.bottom, Spacing.scene.bottom)
        .background(Colors.grayBackground)
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(Localized.Errors.validation("")), message: Text($0))
        }
        .sheet(isPresented: $isPresentingScanner) {
            ScanQRCodeNavigationStack() {
                scanResult($0)
            }
        }
        .onChange(of: secretPhrase) { oldValue, newValue in
            wordSuggestion = model.wordSuggestionCalculate(value: newValue)
        }
        .onChange(of: importType) {
            focusedField = importType.field
        }
        .navigationBarTitle(model.title)
        .taskOnce {
            name = model.name
            importType = model.importTypes.first!
        }
    }

    func selectWord(word: String) {
        secretPhrase = model.selectWordCalculate(input: secretPhrase, word: word)
    }
    
    func scanResult(_ result: String) {
        switch importType {
        case .phrase: secretPhrase = result
        case .address: address = result
        case .privateKey: privateKey = result
        }
    }

    func importWallet() throws {
        let recipient: RecipientImport = {
            if let result = nameResolveState.result {
                return RecipientImport(name: result.name, address: result.address)
            }
            return RecipientImport(name: name, address: address)
        }()
        switch importType {
        case .phrase:
            let words = secretPhrase.split(separator: " ").map{String($0)}
            guard try validateForm(type: importType, address: recipient.address, words: words) else {
                return
            }
            switch model.type {
            case .multicoin:
                try model.importWallet(
                    name: recipient.name,
                    keystoreType: .phrase(words: words, chains: AssetConfiguration.allChains)
                )
            case .chain(let chain):
                try model.importWallet(
                    name: recipient.name,
                    keystoreType: .single(words: words, chain: chain)
                )
            }
        case .privateKey:
            guard try validateForm(type: importType, address: recipient.address, words: [privateKey]) else {
                return
            }
            try model.importWallet(name: recipient.name, keystoreType: .privateKey(text: privateKey, chain: model.chain!))
        case .address:

            try model.importWallet(name: recipient.name, keystoreType: .address(chain: model.chain!, address: recipient.address))
        }
        
        isWalletsPresented.wrappedValue = false
    }
    
    func validateForm(type: WalletImportType, address: String, words: [String]) throws  -> Bool {
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
            guard model.chain!.isValidAddress(address) else {
                throw WalletImportError.invalidAddress
            }
        }
        return true
    }
    
    func paste() {
        guard let string = UIPasteboard.general.string else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        switch importType {
        case .phrase:
            secretPhrase = string.trim()
        case .privateKey:
            privateKey = string.trim()
        case .address:
            address = string.trim()
        }
    }
    
    func scanQR() {
        isPresentingScanner = true
    }
}

extension String: Identifiable {
    public var id: String { self }
}
