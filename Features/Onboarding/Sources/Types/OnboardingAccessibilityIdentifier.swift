// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

enum OnboardingAccessibilityIdentifier: Identifiable {
    case onboardingCreateButton
    case onboardingImportButton
    case acceptTermsToggle(Int)
    case multicoinNavigationLink
    case chainNavigationLink(String)
    case phraseTextField
    case walletImportType(String)

    var id: String {
        switch self {
        case .acceptTermsToggle(let int): "onboarding_acceptTermsToggle_\(int)"
        case .multicoinNavigationLink: "onboarding_multicoinNavigationLink"
        case .chainNavigationLink(let string): "onboarding_chainNavigationLink_\(string)"
        case .phraseTextField: "onboarding_phraseTextField"
        case .walletImportType(let string): "onboarding_walletImportType_\(string)"
        case .onboardingCreateButton: "onboarding_createButton"
        case .onboardingImportButton: "onboarding_importButton"
        }
    }
}

extension View {
    func accessibilityIdentifier(_ identifier: OnboardingAccessibilityIdentifier) -> some View {
        accessibilityIdentifier(identifier.id)
    }
}
