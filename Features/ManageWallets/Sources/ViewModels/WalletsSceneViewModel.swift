import Foundation
import Primitives
import SwiftUI
import Localization
import Preferences
import WalletService
import Components
import Store

@Observable
@MainActor
public final class WalletsSceneViewModel {
#if DEBUG
    public static let walletsLimit = 1000
#else
    public static let walletsLimit = 100
#endif
    
    private let service: WalletService
    private let isPresentingCreateWalletSheet: Binding<Bool>
    private let isPresentingImportWalletSheet: Binding<Bool>
    private let navigationPath: Binding<NavigationPath>

    var isPresentingAlertMessage: AlertMessage?
    var walletDelete: Wallet?
    var currentWalletId: WalletId?

    let pinnedWalletsQuery: ObservableQuery<WalletsRequest>
    let walletsQuery: ObservableQuery<WalletsRequest>

    var pinnedWallets: [Wallet] { pinnedWalletsQuery.value }
    var wallets: [Wallet] { walletsQuery.value }

    public init(
        navigationPath: Binding<NavigationPath>,
        walletService: WalletService,
        isPresentingCreateWalletSheet: Binding<Bool>,
        isPresentingImportWalletSheet: Binding<Bool>
    ) {
        self.navigationPath = navigationPath
        self.service = walletService
        self.currentWalletId = service.currentWalletId
        self.isPresentingAlertMessage = nil
        self.walletDelete = nil
        self.isPresentingCreateWalletSheet = isPresentingCreateWalletSheet
        self.isPresentingImportWalletSheet = isPresentingImportWalletSheet
        self.pinnedWalletsQuery = ObservableQuery(WalletsRequest(isPinned: true), initialValue: [])
        self.walletsQuery = ObservableQuery(WalletsRequest(isPinned: false), initialValue: [])
    }
    
    var title: String {
        Localized.Wallets.title
    }
}

// MARK: - Business Logic

extension WalletsSceneViewModel {
    func setCurrent(_ walletId: WalletId) {
        service.setCurrent(for: walletId)
        currentWalletId = walletId
    }

    func onEdit(wallet: Wallet) {
        navigationPath.wrappedValue.append(Scenes.WalletDetail(wallet: wallet))
    }

    private func delete(_ wallet: Wallet) async throws {
        try await service.delete(wallet)
    }

    private func pin(_ wallet: Wallet) throws {
        if wallet.isPinned {
            try service.unpin(wallet: wallet)
        } else {
            try service.pin(wallet: wallet)
        }
    }

    private func swapOrder(from: WalletId, to: WalletId) throws {
        try service.swapOrder(from: from, to: to)
    }
}

// MARK: - Actions

extension WalletsSceneViewModel {
    func onSelectCreateWallet() {
        guard validate() else {
            return
        }
        isPresentingCreateWalletSheet.wrappedValue.toggle()
    }

    func onSelectImportWallet() {
        guard validate() else {
            return
        }
        isPresentingImportWalletSheet.wrappedValue.toggle()
    }

    func onSelect(wallet: Wallet, dismiss: DismissAction) {
        setCurrent(wallet.walletId)
        dismiss()
    }

    func onMovePinned(from source: IndexSet, to destination: Int) {
        guard let source = source.first else { return }
        do {
            try performSwapOrder(wallets: pinnedWallets, source: source, destination: destination)
        } catch {
            debugLog("WalletsSceneViewModel move pinned error: \(error)")
        }
    }

    func onMove(from source: IndexSet, to destination: Int) {
        guard let source = source.first else { return }
        do {
            try performSwapOrder(wallets: wallets, source: source, destination: destination)
        } catch {
            debugLog("WalletsSceneViewModel move error: \(error)")
        }
    }
    
    func onDelete(wallet: Wallet) {
        walletDelete = wallet
    }
    
    func onPin(wallet: Wallet) {
        do {
            try pin(wallet)
        } catch {
            isPresentingAlertMessage = AlertMessage(message: error.localizedDescription)
        }
    }
    
    func onDeleteConfirmed(wallet: Wallet) async {
        do {
            try await delete(wallet)
            currentWalletId = service.currentWalletId
        } catch {
            isPresentingAlertMessage = AlertMessage(message: error.localizedDescription)
        }
    }
}

// MARK: - Private

extension WalletsSceneViewModel {
    private func validate() -> Bool {
        // fix: https://github.com/gemwalletcom/gem-ios/issues/1067
        if wallets.count > WalletsSceneViewModel.walletsLimit {
            isPresentingAlertMessage = AlertMessage(
                title: Localized.Errors.Wallets.Limit.title,
                message: Localized.Errors.Wallets.Limit.description(WalletsSceneViewModel.walletsLimit)
            )
            return false
        }
        return true
    }

    private func performSwapOrder(wallets: [Wallet], source: Int, destination: Int) throws {
        guard source != destination else { return }

        let from = try wallets.getElement(safe: source)
        if source - destination == 1 { // if next to each other, swap
            let to = try wallets.getElement(safe: destination)
            try swapOrder(
                from: from.walletId,
                to: to.walletId
            )
        } else if source == 0 || wallets.count == destination  { // moving to last position
            for i in source..<destination-1 {
                let to = try wallets.getElement(safe: i+1)
                try swapOrder(
                    from: from.walletId,
                    to: to.walletId
                )
            }
        } else if source == wallets.count-1 { // moving to the first position
            for i in stride(from: wallets.count-1, through: destination+1, by: -1) {
                let to = try wallets.getElement(safe: i-1)
                try swapOrder(
                    from: from.walletId,
                    to: to.walletId
                )
            }
        }
    }
}
