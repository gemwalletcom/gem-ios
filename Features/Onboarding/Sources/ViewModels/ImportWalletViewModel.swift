// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import WalletService
import WalletsService
import AvatarService
import PrimitivesComponents
import Preferences
import enum Keystore.KeystoreImportType

@Observable
@MainActor
public final class ImportWalletViewModel {

    let walletService: WalletService
    let walletsService: WalletsService
    let avatarService: AvatarService
    let nameService: any NameServiceable

    var isPresentingWallets: Binding<Bool>
    var isPresentingSelectImageWallet: Wallet?

    public init(
        walletService: WalletService,
        walletsService: WalletsService,
        avatarService: AvatarService,
        nameService: any NameServiceable,
        isPresentingWallets: Binding<Bool>
    ) {
        self.walletService = walletService
        self.walletsService = walletsService
        self.avatarService = avatarService
        self.nameService = nameService
        self.isPresentingWallets = isPresentingWallets
    }

    public var isAcceptTermsCompleted: Bool {
        walletService.isAcceptTermsCompleted
    }

    func dismiss() {
        isPresentingWallets.wrappedValue = false
    }
    
    private func discoverAssets(wallet: Wallet) {
        Task {
            do {
                try await walletsService.discoverAssets(
                    for: wallet.walletId,
                    preferences: WalletPreferences(walletId: wallet.walletId.id)
                )
            } catch {
                debugLog("Discover assets failed: \(error)")
            }
        }
    }
}

// MARK: - Actions

extension ImportWalletViewModel {
    func presentSelectImage(wallet: Wallet) {
        isPresentingSelectImageWallet = wallet
    }

    func importWallet(data: WalletImportData) async throws -> Wallet {
        let wallet = try await walletService.loadOrCreateWallet(name: data.name, type: data.keystoreType, source: .import)
        walletService.acceptTerms()
        WalletPreferences(walletId: wallet.id).completeInitialSynchronization()
        discoverAssets(wallet: wallet)
        return wallet
    }

    func setupWalletComplete(wallet: Wallet) async throws {
        dismiss()
        try await walletService.setCurrent(wallet: wallet)
    }
}
