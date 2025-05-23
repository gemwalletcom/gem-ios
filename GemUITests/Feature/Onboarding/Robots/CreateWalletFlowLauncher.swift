// Copyright (c). Gem Wallet. All rights reserved.


final class CreateWalletFlowLauncher: Robot {
    
    @discardableResult
    func startCreateFirstWalletFlow() -> Self {
        start(scenario: .createFirstWallet)
        
        return self
    }

    @discardableResult
    func startCreateWalletFlow() -> Self {
        start(scenario: .createWallet)
        
        return self
    }
}
