// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import WalletService
import PrimitivesComponents

@Observable
@MainActor
public final class OnboardingViewModel {
    let walletService: WalletService
    let nameService: any NameServiceable
    let onboardingPresenter: OnboardingPresenter
    let onComplete: () -> Void

    public var isPresentingCreateWalletSheet: Bool = false
    public var isPresentingImportWalletSheet: Bool = false

    public init(
        walletService: WalletService,
        nameService: any NameServiceable,
        onboardingPresenter: OnboardingPresenter,
        onComplete: @escaping () -> Void
    ) {
        self.walletService = walletService
        self.nameService = nameService
        self.onboardingPresenter = onboardingPresenter
        self.onComplete = onComplete
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

    func onWalletSetupComplete(_ oldValue: Bool, _ newValue: Bool) {
        if newValue == false {
            Task {
                try? await Task.sleep(for: .milliseconds(500))
                onboardingPresenter.showEnablePushNotifications()
            }
            onComplete()
        }
    }
}
