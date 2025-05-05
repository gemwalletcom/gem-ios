// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

final class CreateWalletRouter: Router<CreateWalletRouter.Route> {
    enum Route: Hashable {
        case verifyPhrase([String])
        case createWallet
    }
    
    let onComplete: VoidAction
    init(onComplete: VoidAction) {
        self.onComplete = onComplete
    }
    
    func didFinishFlow() {
        onComplete?()
    }
}
