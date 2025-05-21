// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum UITestLaunchScenario: String {
    case onboarding
    
    public init?(info: ProcessInfo) {
        guard let environmentString = info.environment["GemAppUITesting"] else {
            return nil
        }
        
        self.init(rawValue: environmentString)
    }
}
