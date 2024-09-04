// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import QRScanner
import Primitives
import Style

struct AddTokenScene: View {
    @State private var model: AddTokenViewModel

    @FocusState private var focusedField: Field?
    enum Field: Int, Hashable {
        case address
    }

    var action: ((Asset) -> Void)?

    init(model: AddTokenViewModel, action: ((Asset) -> Void)? = nil) {
        self.model = model
        self.action = action
    }

    var body: some View {
        VStack {
            addTokenList
            Spacer()
            StateButton(
                text: model.actionButtonTitlte,
                viewState: model.state,
                action: onSelectImportToken
            )
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .onAppear {
            focusedField = .address
        }
        .onChange(of: model.input.address, onAddressClean)
        .padding(.bottom, Spacing.scene.bottom)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .sheet(isPresented: $model.isPresentingScanner) {
            ScanQRCodeNavigationStack(action: onHandleScan(_:))
        }
        .sheet(isPresented: $model.isPresentingSelectNetwork) {
            NetworkSelectorNavigationStack(
                chains: model.chains,
                onSelectChain: onSelectNewChain(_:)
            )
        }
    }
}

// MARK: - UI Components

extension AddTokenScene {
    @ViewBuilder
    private var addTokenList: some View {
        List {
            if let chain = model.input.chain {
                Section(model.networkTitle) {
                    if model.input.hasManyChains {
                        NavigationCustomLink(with: ChainView(chain: chain), action: onSelectChain)
                    } else {
                        ChainView(chain: chain)
                    }
                }
            }
            Section {
                FloatTextField(model.addressTitleField, text: model.addressBinding) {
                    HStack(spacing: Spacing.medium) {
                        ListButton(image: model.pasteImage, action: onSelectPaste)
                        ListButton(image: model.qrImage, action: onSelectScan)
                    }
                }
                .focused($focusedField, equals: .address)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit(fetch)
            }
            switch model.state {
            case .noData:
                EmptyView()
            case .loading:
                ListItemLoadingView()
                    .id(UUID())
            case .loaded(let asset):
                Section {
                    ListItemView(title: asset.nameTitle, subtitle: asset.name)
                    ListItemView(title: asset.symbolTitle, subtitle: asset.symbol)
                    ListItemView(title: asset.decimalsTitle, subtitle: asset.decimals)
                    ListItemView(title: asset.typeTitle, subtitle: asset.type)
                }
                if let url = asset.explorerUrl {
                    Section {
                        NavigationCustomLink(with: ListItemView(title: asset.explorerText)) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            case .error(let error):
                ListItemErrorView(
                    errorTitle: model.errorTitle,
                    errorSystemNameImage: model.errorSystemImage,
                    error: error
                )
            }
        }
    }
}

// MARK: - Actions

extension AddTokenScene {
    @MainActor
    private func onSelectNewChain(_ chain: Chain) {
        model.input.chain = chain
        onAddressClean(nil, nil)
    }

    @MainActor
    private func onSelectImportToken() {
        guard case let .loaded(asset) = model.state else { return }
        action?(asset.asset)
    }

    @MainActor
    private func onSelectChain() {
        model.isPresentingSelectNetwork = true
    }

    @MainActor
    private func onSelectScan() {
        model.isPresentingScanner = true
    }

    @MainActor
    private func onSelectPaste() {
        guard let address = UIPasteboard.general.string else { return }
        model.input.address = address
        fetch()
    }

    @MainActor
    private func onHandleScan(_ result: String) {
        model.input.address = result
        fetch()
    }

    @MainActor
    private func onAddressClean(_ oldValue: String?, _ newValue: String?) {
        guard newValue == nil else { return }
        model.input.address = newValue
        fetch()
    }
}

// MARK: - Effects

extension AddTokenScene {
    private func fetch() {
        Task {
            await model.fetch()
        }
    }
}

// MARK: - Previews

#Preview {
    let service = AddTokenService.init(chainServiceFactory: ChainServiceFactory(nodeProvider: NodeService(nodeStore: .main)))
    return AddTokenScene(model: AddTokenViewModel(wallet: .main, service: service))
}
