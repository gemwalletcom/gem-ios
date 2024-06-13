import Foundation
import Keystore
import SwiftUI
import Components
import Style

struct WalletDetailScene: View {
    let model: WalletDetailViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var words: [String]? = nil

    @State private var isPresentingErrorMessage: String?
    @State private var isPresentingDeleteConfirmation: Bool?

    init(model: WalletDetailViewModel) {
        self.model = model
        _name = State(initialValue: self.model.name)
    }
    
    var body: some View {
        VStack {
            List {
                Section {
                    FloatTextField(Localized.Wallet.name, text: $name)
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
                case .view:
                    EmptyView()
                }
                Section {
                    switch model.address {
                    case .account(let account):
                        AddressListItem(title: Localized.Common.address, style: .short, account: account)
                    case .none:
                        EmptyView()
                    }
                }
            }
            Spacer()
            Button(Localized.Common.delete, action: onSelectDelete)
                .buttonStyle(.delete())
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .padding(.bottom, Spacing.scene.bottom)
        .background(Colors.grayBackground)
        .frame(maxWidth: .infinity)
        .onChange(of: name, onChangeWalletName)
        .navigationTitle(model.title)
        .confirmationDialog(
            Localized.Wallet.deleteWalletConfirmation(model.name),
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
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(Localized.Errors.transfer("")), message: Text($0))
        }
        .navigationDestination(for: $words) { words in
            ShowSecretPhraseScene(model: ShowSecretPhraseViewModel(words: words))
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
                words = try await model.getMnemonicWords()
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
}

// MARK: - Previews

#Preview {
    NavigationStack {
        WalletDetailScene(model: .init(wallet: .main, keystore: LocalKeystore.main))
            .toolbarTitleDisplayMode(.inline)
    }
}
