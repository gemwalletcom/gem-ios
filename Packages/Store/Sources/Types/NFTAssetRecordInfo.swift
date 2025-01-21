// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

struct NFTAssetRecordInfo: Codable, FetchableRecord {
    let nftAsset: NFTAssetRecord
    let image: NFTImageRecord
    let attributes: [NFTAttributeRecord]
}

extension NFTAssetRecordInfo {
    func mapToNFTAsset() -> NFTAsset {
        NFTAsset(
            id: nftAsset.id,
            collectionId: nftAsset.collectionId,
            tokenId: nftAsset.tokenId,
            tokenType: nftAsset.tokenType,
            name: nftAsset.name,
            description: nftAsset.description,
            chain: nftAsset.chain,
            image: image.mapToNFTImage(),
            attributes: attributes.map { $0.mapToNFTAttribute() }
        )
    }
}
