// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct NFTCollectionRecordInfo: Codable, FetchableRecord {
    let collection: NFTCollectionRecord
    let assets: [NFTAssetRecord]
}

extension NFTCollectionRecordInfo {
    func mapToNFTData() -> NFTData {
        return NFTData(
            collection: NFTCollection(
                id: collection.id,
                name: collection.name,
                description: collection.description,
                chain: collection.chain,
                contractAddress: collection.contractAddress,
                image: NFTImage(
                    imageUrl: collection.imageUrl,
                    previewImageUrl: collection.previewImageUrl,
                    originalSourceUrl: collection.imageUrl
                ),
                isVerified: collection.isVerified,
                links: collection.links ?? []
            ),
            assets: assets.map { $0.mapToAsset() }
        )
    }
}
