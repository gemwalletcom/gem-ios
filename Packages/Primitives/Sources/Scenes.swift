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
    
    public struct CollectionsScene: Hashable {

        public enum SceneStep: Hashable, Sendable {
            case collections
            case collection(NFTData)
        }
        
        public let sceneStep: SceneStep

        public init(sceneStep: SceneStep) {
            self.sceneStep = sceneStep
        }
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
    
    public struct Perpetual: Hashable {
        public let perpetualData: PerpetualData
        
        public init(_ perpetualData: PerpetualData) {
            self.perpetualData = perpetualData
        }
    }
    
    public struct AssetPriceAlert: Hashable {
        public let asset: Primitives.Asset

        public init(asset: Primitives.Asset) {
            self.asset = asset
        }
    }
}
