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

    var isPresentingWallets: Binding<Bool>
    var isPresentingSelectImageWallet: Wallet?

    public init(
        walletService: WalletService,
        avatarService: AvatarService,
        isPresentingWallets: Binding<Bool>
    ) {
        self.walletService = walletService
        self.avatarService = avatarService
        self.isPresentingWallets = isPresentingWallets
        self.hasExistingWallets = walletService.wallets.isNotEmpty
    }

    public var isAcceptTermsCompleted: Bool {
        walletService.isAcceptTermsCompleted
    }

    func dismiss() {
        isPresentingWallets.wrappedValue = false
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
        return wallet
    }

    func setupWalletComplete(wallet: Wallet) async throws {
        try await walletService.setCurrent(wallet: wallet)
        dismiss()
    }
}
