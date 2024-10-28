// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB

struct Columns {
    struct Price {
        static let assetId = Column("assetId")
        static let price = Column("price")
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
        static let available = Column("available")
        static let frozen = Column("frozen")
        static let locked = Column("locked")
        static let staked = Column("staked")
        static let pending = Column("pending")
        static let reserved = Column("reserved")
        static let total = Column("total")
        static let fiatValue = Column("fiatValue")
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
}
