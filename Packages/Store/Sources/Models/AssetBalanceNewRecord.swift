// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

// Only used to create record. totalAmount is computed property and throws an error

struct AssetBalanceNewRecord: Codable, PersistableRecord  {
    
    static let databaseTableName: String = BalanceRecord.databaseTableName
    
    var assetId: AssetId
    var walletId: String
    var isEnabled: Bool
}
