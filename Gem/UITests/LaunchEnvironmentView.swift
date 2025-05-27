// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import WalletServiceTestKit
import PreferencesTestKit
import WalletService
import KeystoreTestKit
import Keystore

// Features
import Onboarding

public struct LaunchEnvironmentView: View {
    let launchEnvironment: UITestLaunchScenario
    
    public init(launchEnvironment: UITestLaunchScenario) {
        self.launchEnvironment = launchEnvironment
    }
    
    public var body: some View {
        switch launchEnvironment {
            case .onboarding:
            OnboardingScene(
                model: OnboardingViewModel(walletService: .mock()),
                isPresentingCreateWalletSheet: .constant(false),
                isPresentingImportWalletSheet: .constant(false)
            )
        case .createFirstWallet:
            CreateWalletNavigationStack(
                walletService: .mock(isAccepted: false),
                isPresentingWallets: .constant(false)
            )
        case .createWallet:
            CreateWalletNavigationStack(
                walletService: .mock(isAccepted: true),
                isPresentingWallets: .constant(false)
            )
        case .importWallet:
            ImportWalletNavigationStack(
                model: ImportWalletTypeViewModel(walletService: .mock(isAccepted: true)),
                isPresentingWallets: .constant(false)
            )
        
        case .exportWords:
            ExportWalletNavigationStack(flow: .words(LocalKeystore.words))
        case .exportPrivateKey:
            ExportWalletNavigationStack(flow: .privateKey(LocalKeystore.privateKey))
        }
    }
}

extension WalletService {
    static func mock(isAccepted: Bool) -> Self {
        .mock(
            keystore: KeystoreMock(),
            preferences: .mock(
                preferences: .mock(
                    defaults: .mockWithValues(values: ["is_accepted_terms": isAccepted])
                )
            )
        )
    }
}
