// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension NFTAsset {
    static func mock(
        id: String = .empty,
        collectionId: String = .empty,
        contractAddress: String? = nil,
        tokenId: String = .empty,
        tokenType: NFTType = .erc721,
        name: String = "Test Name",
        description: String? = nil,
        chain: Chain = .mock(),
        resource: NFTResource = .mock(),
        images: NFTImages = NFTImages(preview: .mock()),
        attributes: [NFTAttribute] = []
    )-> NFTAsset {
        NFTAsset(
            id: id,
            collectionId: collectionId,
            contractAddress: contractAddress,
            tokenId: tokenId,
            tokenType: tokenType,
            name: name,
            description: description,
            chain: chain,
            resource: resource,
            images: images,
            attributes: attributes
        )
    }
}
