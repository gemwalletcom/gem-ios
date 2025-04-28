// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

// Only used to create record. totalAmount is computed property and throws an error

public struct AssetBalanceNewRecord: Codable, PersistableRecord  {
    
    public static let databaseTableName: String = BalanceRecord.databaseTableName
    
    public var assetId: AssetId
    public var walletId: String
    public var isEnabled: Bool
}
