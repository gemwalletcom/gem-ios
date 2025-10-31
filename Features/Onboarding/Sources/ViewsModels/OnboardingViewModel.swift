// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import WalletService
import PrimitivesComponents
import BannerService

@Observable
@MainActor
public final class OnboardingViewModel {
    let walletService: WalletService
    let nameService: any NameServiceable
    let bannerSetupService: BannerSetupService

    public var isPresentingCreateWalletSheet: Bool = false
    public var isPresentingImportWalletSheet: Bool = false

    public init(
        walletService: WalletService,
        nameService: any NameServiceable,
        bannerSetupService: BannerSetupService
    ) {
        self.walletService = walletService
        self.nameService = nameService
        self.bannerSetupService = bannerSetupService
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
