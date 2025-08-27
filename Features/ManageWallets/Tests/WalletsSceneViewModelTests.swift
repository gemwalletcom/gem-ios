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
        let walletStore = WalletStore.mock(db: .mock())
        let wallet1 = Wallet.mock(id: "1")
        let wallet2 = Wallet.mock(id: "2")
        let wallet3 = Wallet.mock(id: "3")
        try walletStore.addWallet(wallet1)
        try walletStore.addWallet(wallet2)
        try walletStore.addWallet(wallet3)

        let service = WalletService.mock(walletStore: walletStore)
        service.setCurrent(for: wallet1.walletId)

        let viewModel = WalletsSceneViewModel.mock(walletService: service)
        #expect(viewModel.currentWalletId == wallet1.walletId)

        viewModel.onDeleteConfirmed(wallet: wallet1)
        #expect(viewModel.currentWalletId == wallet2.walletId)

        viewModel.onDeleteConfirmed(wallet: wallet2)
        #expect(viewModel.currentWalletId == wallet3.walletId)

        viewModel.onDeleteConfirmed(wallet: wallet3)
        #expect(viewModel.currentWalletId == .none)
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
