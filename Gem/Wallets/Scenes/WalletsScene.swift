import SwiftUI
import Components
import Keystore
import Primitives
import GRDBQuery
import Store
import Style

struct WalletsScene: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.db) private var DB

    @State private var isPresentingErrorMessage: String?
    @State private var showingDeleteAlert = false
    
    @State private var isPresentingCreateWalletSheet = false
    @State private var isPresentingImportWalletSheet = false

    @State var walletEdit: Wallet? = .none
    @State var walletDelete: Wallet? = .none

    var model: WalletsViewModel

    @Query<WalletsRequest>
    var wallets: [Wallet]

    init(
        model: WalletsViewModel
    ) {
        self.model = model
        _wallets = Query(WalletsRequest(), in: \.db.dbQueue)
    }
    
    var body: some View {
        List {
            Section {
                Button(
                    action: onSelectCreateWallet,
                    label: {
                        HStack {
                            Image(.createWallet)
                            Text(Localized.Wallet.createNewWallet)
                        }
                    }
                )
                Button(
                    action: onSelectImportWallet,
                    label: {
                        HStack {
                            Image(.importWallet)
                            Text(Localized.Wallet.importExistingWallet)
                        }
                    }
                )
            }
            Section {
                ForEach(wallets.map { WalletViewModel(wallet: $0) }) { wallet in
                    // https://www.jessesquires.com/blog/2023/07/18/navigation-link-accessory-view-swiftui
                    // Hack to hide chevron
                    ZStack {
                        NavigationCustomLink(
                            with: EmptyView(),
                            action: { onSelect(wallet: wallet.wallet) }
                        )
                        .opacity(0)

                        HStack {
                            AssetImageView(assetImage: wallet.assetImage, size: Sizing.image.chain)
                            ListItemView(title: wallet.name, titleExtra: wallet.subType)
                            
                            Spacer()
                            
                            if model.currentWallet == wallet.wallet {
                                Image(.walletSelected)
                            }

                            Button(
                                action: { onSelectEdit(wallet: wallet.wallet) },
                                label: {
                                    Image(.editIcon)
                                        .padding(.vertical, 8)
                                        .padding(.leading, Spacing.small)
                                }
                            )
                            .buttonStyle(.borderless)
                        }
                    }
                    .contextMenu {
                        ContextMenuItem(
                            title: Localized.Common.wallet,
                            image: SystemImage.settings
                        ) {
                            onSelectEdit(wallet: wallet.wallet)
                        }
                        ContextMenuPin {
                            onPin(wallet: wallet.wallet)
                        }
                        ContextMenuDelete {
                            onSelectDelete(wallet: wallet.wallet)
                        }
                    }
                    .swipeActions {
                        Button(
                            action: { onSelectEdit(wallet: wallet.wallet) },
                            label: {
                                Label("", systemImage: SystemImage.settings)
                            }
                        )
                        .tint(Colors.gray)
                        Button(
                            Localized.Common.delete,
                            action: { onSelectDelete(wallet: wallet.wallet) }
                        )
                        .tint(Colors.red)
                    }
                }
            }
        }
        .navigationDestination(for: $walletEdit) { wallet in
            WalletDetailScene(
                model: WalletDetailViewModel(wallet: wallet, keystore: model.keystore)
            )
        }
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(""), message: Text($0))
        }
        .sheet(isPresented: $isPresentingCreateWalletSheet) {
            CreateWalletNavigationStack(isPresenting: $isPresentingCreateWalletSheet)
        }
        .sheet(isPresented: $isPresentingImportWalletSheet) {
            ImportWalletNavigationStack(isPresenting: $isPresentingImportWalletSheet)
        }
        .confirmationDialog(
            Localized.Common.deleteConfirmation(walletDelete?.name ?? ""),
            presenting: $walletDelete,
            sensoryFeedback: .warning,
            actions: { wallet in
                Button(
                    Localized.Common.delete,
                    role: .destructive,
                    action: { delete(wallet: wallet) }
                )
            })
        .navigationBarTitle(model.title)
    }
}


// MARK: - Actions

extension WalletsScene {
    private func onSelectCreateWallet() {
        isPresentingCreateWalletSheet.toggle()
    }

    private func onSelectImportWallet() {
        isPresentingImportWalletSheet.toggle()
    }

    private func onSelectDelete(wallet: Wallet) {
        walletDelete = wallet
    }

    private func onSelectEdit(wallet: Wallet) {
        walletEdit = wallet
    }

    private func onSelect(wallet: Wallet) {
        model.setCurrent(wallet.walletId)
        dismiss()
    }

    private func onPin(wallet: Wallet) {
        //walletEdit = wallet
    }
}

// MARK: - Effects

extension WalletsScene {
    private func delete(wallet: Wallet) {
        Task {
            do {
                try model.delete(wallet)
            } catch {
                isPresentingErrorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        WalletsScene(model: .init(keystore: LocalKeystore.main))
            .navigationBarTitleDisplayMode(.inline)
    }
}
