// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB

// Only used to create record. totalAmount is computed property and throws an error

public struct AssetBalanceNewRecord: Codable, PersistableRecord  {
    
    public static let databaseTableName: String = AssetBalanceRecord.databaseTableName
    
    public var assetId: String
    public var walletId: String
    public var isEnabled: Bool
}
