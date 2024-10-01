import SwiftUI
import Components
import Keystore
import Primitives
import GRDBQuery
import Store
import Style

struct WalletsScene: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.keystore) private var keystore

    @State private var isPresentingErrorMessage: String?
    @State private var showingDeleteAlert = false

    @Binding private var isPresentingCreateWalletSheet: Bool
    @Binding private var isPresentingImportWalletSheet: Bool

    @State var walletDelete: Wallet? = .none

    var model: WalletsViewModel

    @Query<WalletsRequest>
    private var pinnedWallets: [Wallet]

    @Query<WalletsRequest>
    private var wallets: [Wallet]

    init(
        model: WalletsViewModel,
        isPresentingCreateWalletSheet: Binding<Bool>,
        isPresentingImportWalletSheet: Binding<Bool>
    ) {
        self.model = model
        _pinnedWallets = Query(WalletsRequest(isPinned: true))
        _wallets = Query(WalletsRequest(isPinned: false))
        
        _isPresentingCreateWalletSheet = isPresentingCreateWalletSheet
        _isPresentingImportWalletSheet = isPresentingImportWalletSheet
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
                    .onMove(perform: onMovePinned)
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
                .onMove(perform: onMove)
            }
        }
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(""), message: Text($0))
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
            }
        )
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
        model.onEdit(wallet: wallet)
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
        guard let source = source.first else { return }
        do {
            try swapOrder(wallets: pinnedWallets, source: source, destination: destination)
        } catch {
            NSLog("onMovePinned error: \(error)")
        }
    }

    private func onMove(from source: IndexSet, to destination: Int) {
        guard let source = source.first else { return }
        do {
            try swapOrder(wallets: wallets, source: source, destination: destination)
        } catch {
            NSLog("onMove error: \(error)")
        }
    }

    private func swapOrder(wallets: [Wallet], source: Int, destination: Int) throws {
        NSLog("swapOrder source: \(source) destination: \(destination)")

        let from = try wallets.getElement(safe: source)
        if source - destination == 1 { // if next to each other, swap
            let to = try wallets.getElement(safe: destination)
            try model.swapOrder(
                from: from.walletId,
                to: to.walletId
            )
        } else if source == 0 || wallets.count == destination  { // moving to last position
            for i in source..<destination-1 {
                let to = try wallets.getElement(safe: i+1)
                try model.swapOrder(
                    from: from.walletId,
                    to: to.walletId
                )
            }
        } else if source == wallets.count-1 { // moving to the first position
            for i in stride(from: wallets.count-1, through: destination+1, by: -1) {
                let to = try wallets.getElement(safe: i-1)
                try model.swapOrder(
                    from: from.walletId,
                    to: to.walletId
                )
            }
        }
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
        WalletsScene(
            model: .init(
                navigationPath: Binding.constant(NavigationPath()),
                walletService: .main
            ),
            isPresentingCreateWalletSheet: Binding.constant(false),
            isPresentingImportWalletSheet: Binding.constant(false)
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}
