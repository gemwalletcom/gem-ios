// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct AccessibilityIdentifier {

    public enum Common: String, Identifiable {
        case safariInfoButton
        case stateButton
        case doneButton = "Done"
        case cancelButton = "Cancel"
        case floatTextField
        case xCircleCleanButton = "multiply.circle.fill"
        
        public var id: String { rawValue }
    }
    
    public enum Onboarding: Identifiable {
        case acceptTermsToggle(Int)
        case multicoinNavigationLink
        case chainNavigationLink(String)
        case phraseTextField
        case walletImportType(String)

        public var id: String {
            switch self {
            case .acceptTermsToggle(let int): "onboarding_acceptTermsToggle_\(int)"
            case .multicoinNavigationLink: "onboarding_multicoinNavigationLink"
            case .chainNavigationLink(let string): "onboarding_chainNavigationLink_\(string)"
            case .phraseTextField: "onboarding_phraseTextField"
            case .walletImportType(let string): "onboarding_walletImportType_\(string)"
            }
        }
    }
}
