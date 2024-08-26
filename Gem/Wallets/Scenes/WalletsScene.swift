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
    @Environment(\.keystore) private var keystore

    @State private var isPresentingErrorMessage: String?
    @State private var showingDeleteAlert = false
    
    @State private var isPresentingCreateWalletSheet = false
    @State private var isPresentingImportWalletSheet = false

    @State var walletEdit: Wallet? = .none
    @State var walletDelete: Wallet? = .none

    var model: WalletsViewModel

    @Query<WalletsRequest>
    private var pinnedWallets: [Wallet]

    @Query<WalletsRequest>
    private var wallets: [Wallet]

    init(
        model: WalletsViewModel
    ) {
        self.model = model
        _pinnedWallets = Query(WalletsRequest(isPinned: true), in: \.db.dbQueue)
        _wallets = Query(WalletsRequest(isPinned: false), in: \.db.dbQueue)
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
            if !pinnedWallets.isEmpty {
                Section {
                    ForEach(pinnedWallets) {
                        WalletListItemView(
                            wallet: $0,
                            currentWallet: model.currentWallet,
                            onSelect: onSelect,
                            onEdit: onEdit,
                            onPin: onPin,
                            onDelete: onDelete
                        )
                    }
                    //.onMove(perform: onMovePinned)
                } header: {
                    HStack {
                        Image(systemName: SystemImage.pin)
                        Text(Localized.Common.pinned)
                    }
                }
            }

            Section {
                ForEach(wallets) {
                    WalletListItemView(
                        wallet: $0,
                        currentWallet: model.currentWallet,
                        onSelect: onSelect,
                        onEdit: onEdit,
                        onPin: onPin,
                        onDelete: onDelete
                    )
                }
                //.onMove(perform: onMove)
            }
        }
        .navigationDestination(for: $walletEdit) { wallet in
            WalletDetailScene(
                model: WalletDetailViewModel(wallet: wallet, keystore: keystore)
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

    private func onDelete(wallet: Wallet) {
        walletDelete = wallet
    }

    private func onEdit(wallet: Wallet) {
        walletEdit = wallet
    }

    private func onSelect(wallet: Wallet) {
        model.setCurrent(wallet.walletId)
        dismiss()
    }

    private func onPin(wallet: Wallet) {
        do {
            try model.pin(wallet)
        } catch {
            NSLog("onPin error: \(error)")
        }
    }

    private func onMovePinned(from source: IndexSet, to destination: Int) {
        //NSLog("source \(source.first), destination: \(destination)")
    }

    private func onMove(from source: IndexSet, to destination: Int) {
        //NSLog("source \(source.first), destination: \(destination)")
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
        WalletsScene(model: .init(walletService: .main))
            .navigationBarTitleDisplayMode(.inline)
    }
}
