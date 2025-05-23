// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

import Onboarding

struct LaunchEnvironmentView: View {
    @Environment(\.walletService) private var walletService
    
    let launchEnvironment: UITestLaunchScenario
    
    var body: some View {
        switch launchEnvironment {
            case .onboarding:
            OnboardingScene(
                model: OnboardingViewModel(walletService: walletService),
                isPresentingCreateWalletSheet: .constant(false),
                isPresentingImportWalletSheet: .constant(false)
            )
        }
    }
}
