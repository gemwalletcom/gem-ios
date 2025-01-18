// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct NFTCollectionRecordInfo: Codable, FetchableRecord {
    let collection: NFTCollectionRecord
    let image: NFTCollectionImageRecord
    let assets: [NFTAssetRecordInfo]
}

extension NFTCollectionRecordInfo {
    func mapToNFTData() -> NFTData {
        NFTData(
            collection: NFTCollection(
                id: collection.id,
                name: collection.name,
                description: collection.description,
                chain: collection.chain,
                contractAddress: collection.contractAddress,
                image: image.mapToNFTImage(),
                isVerified: collection.isVerified
            ),
            assets: assets.map { $0.mapToNFTAsset() }
        )
    }
}
