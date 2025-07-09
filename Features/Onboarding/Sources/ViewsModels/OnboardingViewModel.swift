// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import WalletService

@Observable
@MainActor
public final class OnboardingViewModel {
    let walletService: WalletService
    
    public var isPresentingCreateWalletSheet: Bool = false
    public var isPresentingImportWalletSheet: Bool = false
    
    public init(walletService: WalletService) {
        self.walletService = walletService
    }
    
    var title: String { Localized.Welcome.title }
    var createWalletTitle: String { Localized.Wallet.createNewWallet }
    var importWalletTitle: String { Localized.Wallet.importExistingWallet }
}

// MARK: - Actions

extension OnboardingViewModel {
    public func onCreateWallet() {
        isPresentingCreateWalletSheet = true
    }
    
    public func onImportWallet() {
        isPresentingImportWalletSheet = true
    }
}
