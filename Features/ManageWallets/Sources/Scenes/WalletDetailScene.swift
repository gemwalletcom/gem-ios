// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import SwiftUI
import Components
import Style
import Primitives
import Localization
import PrimitivesComponents

public struct WalletDetailScene: View {
    let model: WalletDetailViewModel

    enum Field: Int, Hashable {
        case name
    }

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var words: [String]? = nil
    @State private var privateKey: ExportPrivateKey? = nil

    @State private var isPresentingErrorMessage: String?
    @State private var isPresentingDeleteConfirmation: Bool?
    @FocusState private var focusedField: Field?

    public init(model: WalletDetailViewModel) {
        self.model = model
        _name = State(initialValue: self.model.name)
    }
    
    public var body: some View {
        VStack {
            List {
                Section {
                    FloatTextField(Localized.Wallet.name, text: $name, allowClean: focusedField == .name)
                        .focused($focusedField, equals: .name)
                } header: {
                    HStack {
                        Spacer()
                        Button(action: onSelectImage) {
                            AssetImageView(
                                assetImage: model.image,
                                size: Sizing.image.medium * 1.6,
                                overlayImageSize: Spacing.large
                            )
                            .padding(.bottom, Spacing.extraLarge)
                        }
                        Spacer()
                    }
                }
                switch model.wallet.type {
                case .multicoin, .single:
                    Section {
                        NavigationCustomLink(
                            with: ListItemView(title: Localized.Common.show(Localized.Common.secretPhrase)),
                            action: onShowSecretPhrase
                        )
                    } header: {
                        Text(Localized.Common.secretPhrase)
                    }
                case .privateKey:
                    Section {
                        NavigationCustomLink(
                            with: ListItemView(title: Localized.Common.show(Localized.Common.privateKey)),
                            action: onShowPrivateKey
                        )
                    } header: {
                        Text(Localized.Common.privateKey)
                    }
                case .view:
                    EmptyView()
                }
                Section {
                    switch model.address {
                    case .account(let account):
                        AddressListItemView(
                            title: Localized.Common.address,
                            style: .short,
                            account: account,
                            explorerService: model.explorerService
                        )
                    case .none:
                        EmptyView()
                    }
                }
                Section {
                    HStack {
                        Spacer()
                        Button(role: .destructive, action: onSelectDelete) {
                            Text(Localized.Common.delete)
                                .foregroundStyle(Colors.red)
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding(.bottom, Spacing.scene.bottom)
        .background(Colors.grayBackground)
        .frame(maxWidth: .infinity)
        .onChange(of: name, onChangeWalletName)
        .navigationTitle(model.title)
        .confirmationDialog(
            Localized.Common.deleteConfirmation(model.name),
            presenting: $isPresentingDeleteConfirmation,
            sensoryFeedback: .warning,
            actions: { _ in
                Button(
                    Localized.Common.delete,
                    role: .destructive,
                    action: onDeleteWallet
                )
            }
        )
        .alert(
            Localized.Errors.transfer(""),
            isPresented: $isPresentingErrorMessage.mappedToBool(),
            actions: {},
            message: {
                Text(isPresentingErrorMessage ?? "")
            }
        )
        .navigationDestination(for: $words) { words in
            ShowSecretDataScene(model: ShowSecretPhraseViewModel(words: words))
        }
        .navigationDestination(for: $privateKey) {
            ShowSecretDataScene(model: ShowPrivateKeyViewModel(text: $0.key, encoding: model.getEncodingType(for: $0.chain)))
        }
    }
}

// MARK: - Actions

extension WalletDetailScene {
    private func onChangeWalletName() {
        do {
            try model.rename(name: name)
        } catch {
            isPresentingErrorMessage = error.localizedDescription
        }
    }

    private func onShowSecretPhrase() {
        Task {
            do {
                words = try model.getMnemonicWords()
            } catch {
                isPresentingErrorMessage = error.localizedDescription
            }
        }
    }

    private func onShowPrivateKey() {
        Task {
            do {
                //In the future it should allow to export PK for multichain wallet and specify the chain
                let chain = model.wallet.accounts[0].chain
                privateKey = ExportPrivateKey(
                    chain: chain,
                    key: try model.getPrivateKey(for: chain)
                )
            } catch {
                isPresentingErrorMessage = error.localizedDescription
            }
        }
    }

    private func onSelectDelete() {
        isPresentingDeleteConfirmation = true
    }

    private func onDeleteWallet()  {
        do {
            try model.delete()
            dismiss()
        } catch {
            isPresentingErrorMessage = error.localizedDescription
        }
    }

    private func onSelectImage() {
        model.onSelectImage()
    }
}
