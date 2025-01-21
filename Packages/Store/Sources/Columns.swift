// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB

struct Columns {
    struct Price {
        static let assetId = Column("assetId")
        static let price = Column("price")
        static let priceChangePercentage24h = Column("priceChangePercentage24h")
        static let marketCap = Column("marketCap")
        static let marketCapFdv = Column("marketCapFdv")
        static let marketCapRank = Column("marketCapRank")
        static let totalVolume = Column("totalVolume")
        static let circulatingSupply = Column("circulatingSupply")
        static let totalSupply = Column("totalSupply")
        static let maxSupply = Column("maxSupply")
    }
    
    struct Asset {
        static let id = Column("id")
        static let rank = Column("rank")
        static let type = Column("type")
        static let chain = Column("chain")
        static let name = Column("name")
        static let symbol = Column("symbol")
        static let decimals = Column("decimals")
        static let tokenId = Column("tokenId")
        static let isBuyable = Column("isBuyable")
        static let isSellable = Column("isSellable")
        static let isSwappable = Column("isSwappable")
        static let isStakeable = Column("isStakeable")
        static let stakingApr = Column("stakingApr")
    }
    
    struct AssetLink {
        static let assetId = Column("assetId")
        static let name = Column("name")
        static let url = Column("url")
    }
    
    struct Wallet {
        static let id = Column("id")
        static let name = Column("name")
        static let index = Column("index")
        static let type = Column("type")
        static let order = Column("order")
        static let isPinned = Column("isPinned")
    }
    
    struct Account {
        static let walletId = Column("walletId")
        static let chain = Column("chain")
        static let address = Column("address")
        static let index = Column("index")
        static let extendedPublicKey = Column("extendedPublicKey")
        static let derivationPath = Column("derivationPath")
    }
    
    struct AssetDetail {
        static let assetId = Column("assetId")
        static let stakingApr = Column("stakingApr")
    }
    
    struct Transaction {
        static let id = Column("id")
        static let walletId = Column("walletId")
        static let transactionId = Column("transactionId")
        static let hash = Column("hash")
        static let state = Column("state")
        static let assetId = Column("assetId")
        static let type = Column("type")
        static let fee = Column("fee")
        static let date = Column("date")
        static let chain = Column("chain")
        static let blockNumber = Column("blockNumber")
        static let createdAt = Column("createdAt")
    }
    
    struct TransactionAssetAssociation {
        static let assetId = Column("assetId")
        static let transactionId = Column("transactionId")
    }
    
    struct StakeDelegation {
        static let id = Column("id")
        static let walletId = Column("walletId")
        static let assetId = Column("assetId")
        static let state = Column("state")
    }
    
    struct StakeValidator {
        static let id = Column("id")
        static let assetId = Column("assetId")
        static let validatorId = Column("validatorId")
        static let isActive = Column("isActive")
        static let apr = Column("apr")
    }
    
    struct Balance {
        static let assetId = Column("assetId")
        static let walletId = Column("walletId")
        static let isEnabled = Column("isEnabled")
        static let isHidden = Column("isHidden")
        static let isPinned = Column("isPinned")
        static let isActive = Column("isActive")
        static let available = Column("available")
        static let availableAmount = Column("availableAmount")
        static let frozen = Column("frozen")
        static let frozenAmount = Column("frozenAmount")
        static let locked = Column("locked")
        static let lockedAmount = Column("lockedAmount")
        static let staked = Column("staked")
        static let stakedAmount = Column("stakedAmount")
        static let pending = Column("pending")
        static let pendingAmount = Column("pendingAmount")
        static let rewards = Column("rewards")
        static let rewardsAmount = Column("rewardsAmount")
        static let reserved = Column("reserved")
        static let reservedAmount = Column("reservedAmount")
        static let totalAmount = Column("totalAmount")
        static let lastUsedAt = Column("lastUsedAt")
        static let updatedAt = Column("updatedAt")
    }
    
    struct Node {
        static let chain = Column("chain")
        static let url = Column("url")
    }
    
    struct Connection {
        static let id = Column("id")
        static let sessionId = Column("sessionId")
    }

    struct Banner {
        static let id = Column("id")
        static let state = Column("state")
        static let event = Column("event")
        static let assetId = Column("assetId")
        static let chain = Column("chain")
        static let walletId = Column("walletId")
    }
    
    struct NFTCollection {
        static let walletId = Column("walletId")
        static let id = Column("id")
        static let name = Column("name")
        static let description = Column("description")
        static let chain = Column("chain")
        static let contractAddress = Column("contractAddress")
        static let image = Column("image")
        static let isVerified = Column("isVerified")
    }
    
    struct NFTAsset {
        static let id = Column("id")
        static let collectionId = Column("collectionId")
        static let tokenId = Column("tokenId")
        static let tokenType = Column("tokenType")
        static let name = Column("name")
        static let description = Column("description")
        static let chain = Column("chain")
        static let image = Column("image")
        static let attributes = Column("attributes")
    }
    
    struct NFTAttribute {
        static let assetId = Column("assetId")
        static let name = Column("name")
        static let value = Column("value")
    }
    
    struct NFTImage {
        static let id = Column("id")
        static let imageUrl = Column("imageUrl")
        static let previewImageUrl = Column("previewImageUrl")
        static let originalSourceUrl = Column("originalSourceUrl")
    }
}
