// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import WalletService
import AvatarService
import PrimitivesComponents
import Preferences
import enum Keystore.KeystoreImportType

@Observable
@MainActor
public final class ImportWalletViewModel {

    let walletService: WalletService
    let avatarService: AvatarService
    let nameService: any NameServiceable

    var isPresentingWallets: Binding<Bool>
    var isPresentingSelectImageWallet: Wallet?

    public init(
        walletService: WalletService,
        avatarService: AvatarService,
        nameService: any NameServiceable,
        isPresentingWallets: Binding<Bool>
    ) {
        self.walletService = walletService
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
        return wallet
    }

    func setupWalletComplete(wallet: Wallet) async throws {
        dismiss()
        try await walletService.setCurrent(wallet: wallet)
    }
}
