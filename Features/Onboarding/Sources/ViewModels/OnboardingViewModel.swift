// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import WalletService
import AvatarService
import PrimitivesComponents

@Observable
@MainActor
public final class OnboardingViewModel {
    let walletService: WalletService
    let avatarService: AvatarService
    let nameService: any NameServiceable

    public var isPresentingCreateWalletSheet: Bool = false
    public var isPresentingImportWalletSheet: Bool = false

    public init(
        walletService: WalletService,
        avatarService: AvatarService,
        nameService: any NameServiceable
    ) {
        self.walletService = walletService
        self.avatarService = avatarService
        self.nameService = nameService
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
