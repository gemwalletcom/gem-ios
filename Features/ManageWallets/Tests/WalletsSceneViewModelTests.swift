// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import SwiftUI
import Primitives
import PrimitivesTestKit
import WalletService
import Store
import StoreTestKit
import WalletServiceTestKit

@testable import ManageWallets

@MainActor
struct WalletsSceneViewModelTests {
    
    @Test
    func onDeleteConfirmed() throws {
        let service: WalletService = try .mockWallets()
        let model = WalletsSceneViewModel.mock(walletService: service)
        model.wallets = service.wallets

        #expect(model.currentWalletId == .mock(id: "1"))

        model.onDeleteConfirmed(wallet: .mock(id: "1"))
        #expect(model.currentWalletId == .mock(id: "2"))

        model.onDeleteConfirmed(wallet: .mock(id: "2"))
        #expect(model.currentWalletId == .mock(id: "3"))

        model.onDeleteConfirmed(wallet: .mock(id: "3"))
        #expect(model.currentWalletId == .none)
    }

    @Test
    func onMove() throws {
        let service: WalletService = try .mockWallets()
        let model = WalletsSceneViewModel.mock(walletService: service)
        model.wallets = service.wallets

        model.onMove(from: IndexSet(integer: 0), to: 0)
        #expect(service.sortedWallets.ids == ["1", "2", "3"])

        model.onMove(from: IndexSet(integer: 1), to: 0)
        #expect(service.sortedWallets.ids == ["2", "1", "3"])

        model.onMove(from: IndexSet(integer: 0), to: 3)
        #expect(service.sortedWallets.ids == ["3", "2", "1"])

        model.onMove(from: IndexSet(integer: 2), to: 0)
        #expect(service.sortedWallets.ids == ["2", "1", "3"])
        
    }
}

// MARK: - Mock Extensions

extension WalletsSceneViewModel {
    static func mock(
        navigationPath: Binding<NavigationPath> = .constant(NavigationPath()),
        walletService: WalletService = .mock(),
        isPresentingCreateWalletSheet: Binding<Bool> = .constant(false),
        isPresentingImportWalletSheet: Binding<Bool> = .constant(false)
    ) -> WalletsSceneViewModel {
        WalletsSceneViewModel(
            navigationPath: navigationPath,
            walletService: walletService,
            isPresentingCreateWalletSheet: isPresentingCreateWalletSheet,
            isPresentingImportWalletSheet: isPresentingImportWalletSheet
        )
    }
}

extension WalletService {
    static func mockWallets() throws -> Self {
        let walletStore = WalletStore.mock(db: .mock())
        let wallet1 = Wallet.mock(id: "1")
        let wallet2 = Wallet.mock(id: "2")
        let wallet3 = Wallet.mock(id: "3")
        try walletStore.addWallet(wallet1)
        try walletStore.addWallet(wallet2)
        try walletStore.addWallet(wallet3)

        let service = WalletService.mock(walletStore: walletStore)
        service.setCurrent(for: wallet1.walletId)
        
        return service
    }
    
    var sortedWallets: [Wallet] {
        wallets.sorted { $0.order < $1.order }
    }
}
