// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct NFTResult: Codable, Sendable {
    public let data: [NFTData]
    
    public init(data: [NFTData]) {
        self.data = data
    }
}

extension NFTData: Identifiable, Hashable, Equatable {
    public var id: String { collection.id }
    
    public static func == (lhs: NFTData, rhs: NFTData) -> Bool {
        lhs.collection == rhs.collection &&
        lhs.assets == rhs.assets
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(collection)
        hasher.combine(assets)
    }
}

extension NFTCollection: Identifiable, Hashable, Equatable {
    public static func == (lhs: NFTCollection, rhs: NFTCollection) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.chain == rhs.chain &&
        lhs.contractAddress == rhs.contractAddress &&
        lhs.image == rhs.image &&
        lhs.isVerified == rhs.isVerified
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension NFTImage: Hashable, Equatable {
    public static func == (lhs: NFTImage, rhs: NFTImage) -> Bool {
        lhs.imageUrl == rhs.imageUrl &&
        lhs.previewImageUrl == rhs.previewImageUrl &&
        lhs.originalSourceUrl == rhs.originalSourceUrl
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(imageUrl)
        hasher.combine(previewImageUrl)
        hasher.combine(originalSourceUrl)
    }
}

extension NFTAsset: Identifiable, Hashable, Equatable {
    public static func == (lhs: NFTAsset, rhs: NFTAsset) -> Bool {
        lhs.id == rhs.id &&
        lhs.collectionId == rhs.collectionId &&
        lhs.tokenId == rhs.tokenId &&
        lhs.tokenType == rhs.tokenType &&
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.chain == rhs.chain &&
        lhs.image == rhs.image &&
        lhs.attributes == rhs.attributes
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension NFTAttribute: Identifiable, Hashable, Equatable {
    public var id: String {
        name + value
    }
    
    public static func == (lhs: NFTAttribute, rhs: NFTAttribute) -> Bool {
        lhs.name == rhs.name &&
        lhs.value == rhs.value
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(value)
    }
}
