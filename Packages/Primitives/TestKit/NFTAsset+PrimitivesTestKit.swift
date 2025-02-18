// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension NFTAsset {
    static func mock(
        id: String = UUID().uuidString,
        collectionId: String = UUID().uuidString,
        contractAddress: String? = nil,
        tokenId: String = UUID().uuidString,
        tokenType: NFTType = .erc721,
        name: String = "Test Name",
        description: String? = nil,
        chain: Chain = .mock(),
        image: NFTImage = .mock(),
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
            image: image,
            attributes: attributes
        )
    }
}
