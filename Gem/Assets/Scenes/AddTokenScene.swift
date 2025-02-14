// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import QRScanner
import Primitives
import Style
import ChainService
import NodeService
import PrimitivesComponents

struct AddTokenScene: View {
    @State private var model: AddTokenViewModel
    @State private var networksModel: NetworkSelectorViewModel

    @FocusState private var focusedField: Field?
    enum Field: Int, Hashable {
        case address
    }

    var action: ((Asset) -> Void)?

    init(model: AddTokenViewModel, action: ((Asset) -> Void)? = nil) {
        _model = State(initialValue: model)
        _networksModel = State(initialValue: NetworkSelectorViewModel(items: model.chains))
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
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .navigationDestination(for: Scenes.NetworksSelector.self) { _ in
            NetworkSelectorScene(
                model: $networksModel,
                onFinishSelection: onFinishChainSelection(chains:)
            )
        }
        .sheet(isPresented: $model.isPresentingScanner) {
            ScanQRCodeNavigationStack(action: onHandleScan(_:))
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
                        NavigationLink(value: Scenes.NetworksSelector()) {
                            ChainView(model: ChainViewModel(chain: chain))
                        }
                    } else {
                        ChainView(model: ChainViewModel(chain: chain))
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
                if let url = asset.explorerUrl, let text = asset.explorerText {
                    Section {
                        NavigationOpenLink(url: url, with: ListItemView(title: text))
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
    private func onFinishChainSelection(chains: [Chain]) {
        model.input.chain = chains.first
        onAddressClean(nil, nil)
    }

    private func onSelectImportToken() {
        guard case let .loaded(asset) = model.state else { return }
        action?(asset.asset)
    }

    private func onSelectScan() {
        model.isPresentingScanner = true
    }

    private func onSelectPaste() {
        guard let address = UIPasteboard.general.string else { return }
        model.input.address = address
        fetch()
    }

    private func onHandleScan(_ result: String) {
        model.input.address = result
        fetch()
    }

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
