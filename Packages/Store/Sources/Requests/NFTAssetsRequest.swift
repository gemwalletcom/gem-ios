// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Primitives
import Combine

public struct NFTAssetsRequest: ValueObservationQueryable {
    public static var defaultValue: [NFTAsset] { [] }
    
    private let walletId: String
    
    public init(walletId: String) {
        self.walletId = walletId
    }
    
    public func fetch(_ db: Database) throws -> [NFTAsset] {
        try NFTAssetRecord
            .joining(
                required: NFTAssetRecord.assetAssociations
                    .filter(Columns.NFTAssetsAssociation.walletId == walletId)
            )
            .fetchAll(db)
            .map { $0.mapToAsset() }
    }
}
