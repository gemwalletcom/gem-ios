// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import WalletService
import AvatarService
import Preferences
import GemstonePrimitives

@Observable
@MainActor
public final class CreateWalletModel {

    let walletService: WalletService
    let avatarService: AvatarService
    let hasExistingWallets: Bool
    let onComplete: VoidAction

    var isPresentingSelectImageWallet: Wallet?

    public init(
        walletService: WalletService,
        avatarService: AvatarService,
        onComplete: VoidAction
    ) {
        self.walletService = walletService
        self.avatarService = avatarService
        self.onComplete = onComplete
        self.hasExistingWallets = walletService.wallets.isNotEmpty
    }

    public var isAcceptTermsCompleted: Bool {
        walletService.isAcceptTermsCompleted
    }

    func dismiss() {
        onComplete?()
    }
}

// MARK: - Actions

extension CreateWalletModel {
    func presentSelectImage(wallet: Wallet) {
        isPresentingSelectImageWallet = wallet
    }

    func createWallet(words: [String]) async throws -> Wallet {
        let wallet = try await walletService.loadOrCreateWallet(
            name: WalletNameGenerator(type: .multicoin, walletService: walletService).name,
            type: .phrase(words: words, chains: AssetConfiguration.allChains),
            source: .create
        )
        walletService.acceptTerms()
        WalletPreferences(walletId: wallet.walletId).completeInitialSynchronization()
        return wallet
    }

    func setupWalletComplete(wallet: Wallet) async throws {
        dismiss()
        try await walletService.setCurrent(wallet: wallet)
    }
}
