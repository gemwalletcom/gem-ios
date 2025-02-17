// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Primitives
import Combine

public struct NFTAssetsRequest: ValueObservationQueryable {
    public static var defaultValue: [NFTAsset] { [] }
    
    public init() {}
    
    public func fetch(_ db: Database) throws -> [NFTAsset] {
        try NFTAssetRecord
            .fetchAll(db)
            .map { $0.mapToAsset() }
    }
}
