// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct AccessibilityIdentifier {

    public enum Common: String, Identifiable {
        case safariInfoButton
        case stateButton
        case doneButton
        case cancelButton
        
        public var id: String { rawValue }
    }
    
    public enum Onboarding: Identifiable {
        case acceptTermsToggle(Int)

        public var id: String {
            switch self {
            case .acceptTermsToggle(let int): "onboarding.acceptTermsToggle.\(int)"
            }
        }
    }
}
