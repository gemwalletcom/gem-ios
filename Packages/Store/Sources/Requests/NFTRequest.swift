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
        try NFTCollectionRecord
            .filter(Columns.NFT.walletId == walletId || Columns.NFT.id == collectionId)
            .including(
                all: NFTCollectionRecord.assets
                    .including(required: NFTAssetRecord.image)
                    .including(all: NFTAssetRecord.attributes)
            )
            .including(required: NFTCollectionRecord.image)
            .asRequest(of: NFTCollectionRecordInfo.self)
            .fetchAll(db)
            .map { $0.mapToNFTData() }
    }
}
