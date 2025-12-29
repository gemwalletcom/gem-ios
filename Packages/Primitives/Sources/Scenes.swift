// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct Scenes {
    public struct CreateWallet: Hashable {
        public init() {}
    }

    public struct ImportWallet: Hashable {
        public init() {}
    }
    
    public struct ImportWalletType: Hashable {
        public init() {}
    }
    
    public struct SecurityReminder: Hashable {
        public init() {}
    }

    public struct Notifications: Hashable {
        public init() {}
    }

    public struct PriceAlerts: Hashable {
        public init() {}
    }

    public struct Chains: Hashable {
        public init() {}
    }

    public struct AboutUs: Hashable {
        public init() {}
    }

    public struct Developer: Hashable {
        public init() {}
    }

    public struct Security: Hashable {
        public init() {}
    }

    public struct Wallets: Hashable {
        public init() {}
    }

    public struct Currency: Hashable {
        public init() {}
    }

    public struct Preferences: Hashable {
        public init() {}
    }

    public struct WalletConnectorScene: Hashable {
        public init() {}
    }

    public struct Validators: Hashable {
        public init() {}
    }

    public struct Stake: Hashable {
        public let chain: Chain
        public let wallet: Wallet

        public init(chain: Chain, wallet: Wallet) {
            self.chain = chain
            self.wallet = wallet
        }
    }

    public struct WalletConnect: Hashable {
        public init() {}
    }

    public struct SelectWallet: Hashable {
        public init() {}
    }

    public struct NetworksSelector: Hashable {
        public init() {}
    }

    public struct VerifyPhrase: Hashable {
        public let words: [String]

        public init(words: [String]) {
            self.words = words
        }
    }

    public struct WalletProfile: Hashable {
        public let wallet: Wallet

        public init(wallet: Wallet) {
            self.wallet = wallet
        }
    }

    public struct WalletDetail: Hashable {
        public let wallet: Wallet

        public init(wallet: Wallet) {
            self.wallet = wallet
        }
    }

    public struct WalletSelectImage: Hashable {
        public let wallet: Wallet

        public init(wallet: Wallet) {
            self.wallet = wallet
        }
    }

    public struct Price: Hashable {
        public let asset: Primitives.Asset

        public init(asset: Primitives.Asset) {
            self.asset = asset
        }
    }

    public struct Asset: Hashable {
        public let asset: Primitives.Asset

        public init(asset: Primitives.Asset) {
            self.asset = asset
        }
    }

    public struct ChainSettings: Hashable {
        public let chain: Primitives.Chain

        public init(chain: Primitives.Chain) {
            self.chain = chain
        }
    }
    
    public struct Collection: Hashable, Sendable {
        public let id: String
        public let name: String

        public init(id: String, name: String) {
            self.id = id
            self.name = name
        }
    }

    public struct UnverifiedCollections: Hashable, Sendable {
        public init() {}
    }

    public struct Collectible: Hashable, Sendable {
        public let assetData: NFTAssetData

        public init(assetData: NFTAssetData) {
            self.assetData = assetData
        }
    }
    
    public struct Perpetuals: Hashable {
        public init() {}
    }

    public struct Referral: Hashable {
        public let code: String?
        public let giftCode: String?

        public init(code: String? = nil, giftCode: String? = nil) {
            self.code = code
            self.giftCode = giftCode
        }
    }
    
    public struct Perpetual: Hashable {
        public let asset: Primitives.Asset

        public init(_ asset: Primitives.Asset) {
            self.asset = asset
        }

        public init(_ perpetualData: PerpetualData) {
            self.asset = perpetualData.asset
        }
    }
    
    public struct AssetPriceAlert: Hashable {
        public let asset: Primitives.Asset
        public let price: Double?

        public init(asset: Primitives.Asset, price: Double? = nil) {
            self.asset = asset
            self.price = price
        }
    }
}
