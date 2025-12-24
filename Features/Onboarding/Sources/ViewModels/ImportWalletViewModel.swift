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
    var navigationPath: NavigationPath = NavigationPath()

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
}

// MARK: - Actions

extension ImportWalletViewModel {
    func onNavigate(to route: ImportWalletRoute) {
        switch route {
        case .importWalletType:
            navigationPath.append(Scenes.ImportWalletType())
        case .selectImage(let wallet):
            navigationPath.append(Scenes.WalletSelectImage(wallet: wallet))
        case .walletProfile(let wallet):
            navigationPath.append(Scenes.WalletProfile(wallet: wallet))
        }
    }

    func onImportComplete(data: WalletImportData) {
        walletService.acceptTerms()
        Task {
            do {
                if hasExistingWallets {
                    let wallet = try await createWallet(data: data)
                    onNavigate(to: .walletProfile(wallet: wallet))
                } else {
                    let wallet = try await createWallet(data: data)
                    try await walletService.setCurrent(wallet: wallet)
                    dismiss()
                }
            } catch {
                debugLog("Failed to import wallet: \(error)")
            }
        }
    }

    private func createWallet(data: WalletImportData) async throws -> Wallet {
        let wallet = try await walletService.loadOrCreateWallet(name: data.name, type: data.keystoreType, source: .import)
        WalletPreferences(walletId: wallet.id).completeInitialSynchronization()
        return wallet
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
