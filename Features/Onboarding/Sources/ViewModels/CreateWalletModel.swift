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

    var isPresentingWallets: Binding<Bool>
    var navigationPath: NavigationPath = NavigationPath()

    public init(
        walletService: WalletService,
        avatarService: AvatarService,
        isPresentingWallets: Binding<Bool>
    ) {
        self.walletService = walletService
        self.avatarService = avatarService
        self.isPresentingWallets = isPresentingWallets
    }

    public var hasExistingWallets: Bool {
        walletService.wallets.isNotEmpty
    }

    public var isAcceptTermsCompleted: Bool {
        walletService.isAcceptTermsCompleted
    }
    
    // MARK: - Private

    private func dismiss() {
        isPresentingWallets.wrappedValue = false
    }
    
    private func createWallet(words: [String]) async throws -> Wallet {
        try await walletService.loadOrCreateWallet(
            name: WalletNameGenerator(type: .multicoin, walletService: walletService).name,
            type: .phrase(words: words, chains: AssetConfiguration.allChains),
            source: .create
        )
    }
}

// MARK: - Actions

extension CreateWalletModel {
    func onNavigate(to route: CreateWalletRoute) {
        switch route {
        case .securityReminder:
            navigationPath.append(Scenes.SecurityReminder())
        case .createWallet:
            navigationPath.append(Scenes.CreateWallet())
        case .verifyPhrase(let words):
            navigationPath.append(Scenes.VerifyPhrase(words: words))
        case .selectImage(let wallet):
            navigationPath.append(Scenes.WalletSelectImage(wallet: wallet))
        }
    }

    func onVerifyPhraseComplete(words: [String]) {
        Task {
            do {
                if hasExistingWallets {
                    let wallet = try await createWallet(words: words)
                    navigationPath.append(Scenes.WalletProfile(wallet: wallet))
                } else {
                    let wallet = try await createWallet(words: words)
                    try await walletService.setCurrent(wallet: wallet)
                    walletService.acceptTerms()
                    dismiss()
                }
            } catch {
                debugLog("Failed to create wallet: \(error)")
            }
        }
    }

    func onSetupWalletComplete(wallet: Wallet) {
        Task {
            do {
                try await walletService.setCurrent(wallet: wallet)
                dismiss()
            } catch {
                debugLog("Failed to import wallet: \(error)")
            }
        }
    }
}
