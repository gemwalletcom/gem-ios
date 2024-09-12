// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

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
    struct Stake: Hashable {
        let chain: Chain
        let wallet: Wallet
    }
    struct WalletConnect: Hashable {}
    struct SelectWallet: Hashable {}
    struct VerifyPhrase: Hashable {
        let words: [String]
    }
    struct WalletDetail: Hashable {
        let wallet: Wallet
    }
    struct WalletSelectImage: Hashable {
        let wallet: Wallet
    }
    struct Price: Hashable {
        let asset: Primitives.Asset
    }
    struct Asset: Hashable {
        let asset: Primitives.Asset
    }
}
