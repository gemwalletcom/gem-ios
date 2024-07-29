// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import QRScanner
import Primitives
import Blockchain
import Style

struct AddTokenScene: View {
    @StateObject var model: AddTokenViewModel

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
                if let chain = model.chain {
                    Section(Localized.Transfer.network) {
                        NavigationCustomLink(with: ChainView(chain: chain), action: onSelectChain)
                    }
                }
                Section {
                    VStack {
                        HStack {
                            FloatTextField(Localized.Wallet.Import.contractAddressField, text: $model.address)
                                .textFieldStyle(.plain)
                                .focused($focusedField, equals: .address)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .submitLabel(.search)
                                .onSubmit(onSubmitAddress)
                            Spacer()
                            HStack(spacing: Spacing.medium) {
                                ListButton(image: Image(systemName: SystemImage.paste), action: onSelectPaste)
                                ListButton(image: Image(systemName: SystemImage.qrCode), action: onSelectScan)
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
                    if let url = asset.explorerUrl {
                        Section {
                            NavigationCustomLink(with: ListItemView(title: asset.explorerText)) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                case .error(let error):
                    ListItemErrorView(errorTitle: model.errorTitle, errorSystemNameImage: SystemImage.errorOccurred, error: error)
                }
            }
            Spacer()
            Button(Localized.Wallet.Import.action, action: onSelectImportToken)
                .disabled(model.state.isLoading)
                .frame(maxWidth: Spacing.scene.button.maxWidth)
                .buttonStyle(.blue())
        }
        .padding(.bottom, Spacing.scene.bottom)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .sheet(isPresented: $isPresentingScanner) {
            ScanQRCodeNavigationStack(action: onHandleScan(_:))
        }
        .sheet(isPresented: $isPresentingSelectNetwork) {
            if let chain = model.chain {
                NetworkSelectorNavigationStack(
                    model: NetworkSelectorViewModel(chains: model.chains, selectedChain: chain),
                    isPresenting: $isPresentingSelectNetwork,
                    onSelectChain: onSelectNewChain(_:)
                )
            }
        }
        .taskOnce(onTaskOnce)
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(""), message: Text($0))
        }
    }
}

// MARK: - Actions

extension AddTokenScene {
    private func onTaskOnce() {
        model.chain = model.defaultChain
    }

    private func onSelectImportToken() {
        switch model.state {
        case .loaded(let asset):
            action?(asset.asset)
        default:
            break
        }
    }

    private func onSelectChain() {
        isPresentingSelectNetwork = true
    }

    private func onSelectScan() {
        isPresentingScanner = true
    }

    private func onSubmitAddress() {
        Task {
            try await addToken(tokenId: model.address)
        }
    }

    private func onSelectPaste() {
        guard let content = UIPasteboard.general.string else {
            return
        }
        model.address = content
        Task {
            try await addToken(tokenId: content)
        }
    }

    private func onHandleScan(_ result: String) {
        Task {
            try await addToken(tokenId: result)
        }
    }

    private func onSelectNewChain(_ chain: Chain) {
        model.chain = chain
    }
}

// MARK: - Data Fetching

extension AddTokenScene {
    private func addToken(tokenId: String) async throws {
        try await model.fetch(tokenId: tokenId)
    }
}

// MARK: - LocalizedError

extension TokenValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidTokenId: Localized.Errors.Token.invalidId
        case .invalidMetadata: Localized.Errors.Token.invalidMetadata
        case .other(let error): Localized.Errors.Token.unableFetchTokenInformation(error.localizedDescription)
        }
    }
}
