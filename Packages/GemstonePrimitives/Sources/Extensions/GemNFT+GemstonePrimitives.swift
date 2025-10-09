// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemNftType {
    public func map() -> NFTType {
        switch self {
        case .erc721: return .erc721
        case .erc1155: return .erc1155
        case .spl: return .spl
        case .jetton: return .jetton
        @unknown default: return .erc721
        }
    }
}

extension NFTType {
    public func map() -> GemNftType {
        switch self {
        case .erc721: return .erc721
        case .erc1155: return .erc1155
        case .spl: return .spl
        case .jetton: return .jetton
        }
    }
}

extension GemNftResource {
    public func map() -> NFTResource {
        NFTResource(url: url, mimeType: mimeType)
    }
}

extension NFTResource {
    public func map() -> GemNftResource {
        GemNftResource(url: url, mimeType: mimeType)
    }
}

extension GemNftImages {
    public func map() -> NFTImages {
        NFTImages(preview: preview.map())
    }
}

extension NFTImages {
    public func map() -> GemNftImages {
        GemNftImages(preview: preview.map())
    }
}

extension GemNftAttribute {
    public func map() -> NFTAttribute {
        NFTAttribute(name: name, value: value, percentage: percentage)
    }
}

extension NFTAttribute {
    public func map() -> GemNftAttribute {
        GemNftAttribute(name: name, value: value, percentage: percentage)
    }
}

extension GemNftAsset {
    public func map() throws -> NFTAsset {
        return NFTAsset(
            id: id,
            collectionId: collectionId,
            contractAddress: contractAddress,
            tokenId: tokenId,
            tokenType: tokenType.map(),
            name: name,
            description: description,
            chain: try Chain(id: chain),
            resource: resource.map(),
            images: images.map(),
            attributes: attributes.map { $0.map() }
        )
    }
}

extension NFTAsset {
    public func map() -> GemNftAsset {
        return GemNftAsset(
            id: id,
            collectionId: collectionId,
            contractAddress: contractAddress,
            tokenId: tokenId,
            tokenType: tokenType.map(),
            name: name,
            description: description,
            chain: chain.rawValue,
            resource: resource.map(),
            images: images.map(),
            attributes: attributes.map { $0.map() }
        )
    }
}
