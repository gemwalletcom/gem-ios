// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import QRScanner
import Primitives
import Blockchain
import Style

struct AddTokenScene: View {
    
    @StateObject var model: AddTokenViewModel
    @State var chain: Chain = .ethereum
    @State private var address: String = ""
    @State private var isPresentingScanner = false
    @State private var isPresentingSelectNetwork = false
    @State private var isPresentingErrorMessage: String?
    @FocusState private var focusedField: Field?
    var action: ((Asset) -> Void)?
    
    enum Field: Int, Hashable {
        case address
    }
    
    var body: some View {
        VStack {
            List {
                Section(Localized.Transfer.network) {
                    NavigationCustomLink(with: ChainView(chain: chain)) {
                        isPresentingSelectNetwork = true
                    }
                }
                Section {
                    VStack {
                        HStack {
                            FloatTextField(Localized.Wallet.Import.contractAddressField, text: $address)
                                .textFieldStyle(.plain)
                                .focused($focusedField, equals: .address)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .submitLabel(.search)
                                .onSubmit {
                                    Task { try await addToken(tokenId: address) }
                                }
                            Spacer()
                            HStack(spacing: Spacing.medium) {
                                ListButton(image: Image(systemName: SystemImage.paste), action: paste)
                                ListButton(image: Image(systemName: SystemImage.qrCode), action: scan)
                            }
                        }
                    }
                }
                switch model.state {
                case .noData:
                    EmptyView()
                case .loading:
                    Section {
                        StateLoadingView()
                    }
                case .loaded(let asset):
                    Section {
                        ListItemView(title: Localized.Asset.name, subtitle: asset.name)
                        ListItemView(title: Localized.Asset.symbol, subtitle: asset.symbol)
                        ListItemView(title: Localized.Asset.decimals, subtitle: asset.decimals)
                        ListItemView(title: Localized.Common.type, subtitle: asset.type)
                    }
                    if let url = asset.url {
                        Section {
                            NavigationCustomLink(with: ListItemView(title: Localized.Transaction.viewOn("Block explorer"))) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                case .error(let error):
                    Section {
                        StateErrorView(error: error, message: error.localizedDescription)
                    }
                }
            }
            Spacer()
            Button(Localized.Wallet.Import.action, action: importToken)
                .disabled(model.state.isLoading)
                .frame(maxWidth: Spacing.scene.button.maxWidth)
                .buttonStyle(BlueButton())
        }
        .padding(.bottom, Spacing.scene.bottom)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .sheet(isPresented: $isPresentingScanner) {
            ScanQRCodeNavigationStack(isPresenting: $isPresentingScanner) {
                scanResult($0)
            }
        }
        .sheet(isPresented: $isPresentingSelectNetwork) {
            NetworkSelectorNavigationStack(chains: model.chains, selectedChain: $chain, isPresenting: $isPresentingSelectNetwork) { _ in
                
            }
        }
        .taskOnce {
            //This is a hack, in the future observer from model.chain
            self.chain = model.defaultChain
        }
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(""), message: Text($0))
        }
    }
    
    func paste() {
        guard let content = UIPasteboard.general.string else {
            return
        }
        address = content
        Task {
            try await addToken(tokenId: content)
        }
    }
    
    func scan() {
        isPresentingScanner = true
    }
    
    func addToken(tokenId: String) async throws {
        try await model.fetch(chain: chain, tokenId: tokenId)
    }
    
    func importToken() {
        switch model.state {
        case .loaded(let asset):
            action?(asset.asset)
        default:
            break
        }
    }
    
    func scanResult(_ result: String) {
        Task {
            try await addToken(tokenId: result)
        }
    }
}

extension TokenValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidTokenId: Localized.Errors.Token.invalidId
        case .invalidMetadata: Localized.Errors.Token.invalidMetadata
        case .other(let error): Localized.Errors.Token.unableFetchTokenInformation(error.localizedDescription)
        }
    }
}
