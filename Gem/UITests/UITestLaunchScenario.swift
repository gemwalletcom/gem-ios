// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum UITestLaunchScenario: String {
    public static let testEnvironmentKey = "GemAppUITesting"

    // Onboarding
    case onboarding
    case createFirstWallet
    case createWallet
    case importWallet
    case exportWords
    case exportPrivateKey
    
    // Gem
    case selectAssetManage
    case assetScene
    
    // ManageWallets
    case walletsList
    
    public init?(info: ProcessInfo) {
        guard let environmentString = info.environment[Self.testEnvironmentKey] else {
            return nil
        }
        
        self.init(rawValue: environmentString)
    }
}
