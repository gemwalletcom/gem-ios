// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

struct NFTAssetRecordInfo: Codable, FetchableRecord {
    let asset: NFTAssetRecord
    let attributes: [NFTAttributeRecord]
}

extension NFTAssetRecordInfo {
    func mapToNFTAsset() -> NFTAsset {
        NFTAsset(
            id: asset.id,
            collectionId: asset.collectionId,
            tokenId: asset.tokenId,
            tokenType: asset.tokenType,
            name: asset.name,
            description: asset.description,
            chain: asset.chain,
            image: NFTImage(
                imageUrl: asset.imageUrl,
                previewImageUrl: asset.previewImageUrl,
                originalSourceUrl: asset.imageUrl
            ),
            attributes: attributes.map { $0.mapToNFTAttribute() }
        )
    }
}
