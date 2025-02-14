// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Primitives
import Combine

public struct NFTRequest: ValueObservationQueryable {
    public static var defaultValue: [NFTData] { [] }
    
    private let walletId: String
    private let collectionId: String?
    
    public init(
        walletId: String,
        collectionId: String?
    ) {
        self.walletId = walletId
        self.collectionId = collectionId
    }
    
    public func fetch(_ db: Database) throws -> [NFTData] {
        var request = NFTCollectionRecord
            .including(
                all: NFTCollectionRecord.assets
                    .joining(
                        required: NFTAssetRecord.assetAssociations
                            .filter(Columns.NFTAssetsAssociation.walletId == walletId)
                    )
            )
            .distinct()
            .asRequest(of: NFTCollectionRecordInfo.self)

        if let collectionId {
            request = request.filter(Columns.NFTCollection.id == collectionId)
        }

        return try request
            .fetchAll(db)
            .map { $0.mapToNFTData() }
            .filter { $0.assets.count > 0 }
    }
}
