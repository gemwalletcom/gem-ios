// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct Scenes {
    struct CreateWallet: Hashable {}
    struct ImportWallet: Hashable {}
    struct FiatProviders: Hashable {}
    struct Notifications: Hashable {}
    struct Chains: Hashable {}
    struct AboutUs: Hashable {}
    struct Developer: Hashable {}
    struct Security: Hashable {}
    struct Wallets: Hashable {}
    struct Currency: Hashable {}
    struct WalletConnections: Hashable {}
    struct WalletConnectorScene: Hashable {}
    struct Validators: Hashable {}
    struct Stake: Hashable {}
    struct WalletConnect: Hashable {}
    struct VerifyPhrase: Hashable {
        let words: [String]
    }
}
