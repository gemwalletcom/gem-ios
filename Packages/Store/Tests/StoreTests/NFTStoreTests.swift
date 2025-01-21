// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import XCTest
import GRDB

@testable import Store

final class NFTStoreTests: XCTestCase {
    let path = "in.memory"
    var db: DB!
    var nftStore: NFTStore!

    override func setUpWithError() throws {
        db = DB(path: path)
        nftStore = NFTStore(db: db)

        try db.dbQueue.write { db in
            try NFTCollectionRecord.create(db: db)
            try NFTAssetRecord.create(db: db)
            try NFTAttributeRecord.create(db: db)
            try NFTImageRecord.create(db: db)
            try NFTCollectionImageRecord.create(db: db)
        }
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        db = nil
        nftStore = nil
        let dbPath = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appending(path: path)
        do { try FileManager.default.removeItem(atPath: dbPath.absoluteString) } catch { }
    }

    func testAddOrUpdateNFTResults() throws {
        let collection = NFTCollection(
            id: "1",
            name: "Test Collection",
            description: "A test NFT collection",
            chain: .ethereum,
            contractAddress: "0x123",
            image: NFTImage(imageUrl: "url1", previewImageUrl: "url2", originalSourceUrl: "url3"),
            isVerified: true
        )
        let asset = NFTAsset(
            id: "1",
            collectionId: "1",
            tokenId: "1",
            tokenType: .erc721,
            name: "Test Asset",
            description: "A test NFT asset",
            chain: .ethereum,
            image: NFTImage(imageUrl: "url4", previewImageUrl: "url5", originalSourceUrl: "url6"),
            attributes: [
                NFTAttribute(name: "Color", value: "Blue"),
                NFTAttribute(name: "Size", value: "Large")
            ]
        )
        let data = [NFTData(collection: collection, assets: [asset])]

        try nftStore.saveNFTData(data, for: "wallet1")

        let results = try nftStore.getNFTResults(for: "wallet1")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.collection.id, "1")
        XCTAssertEqual(results.first?.assets.count, 1)
        XCTAssertEqual(results.first?.assets.first?.attributes.count, 2)
    }
    
    func testAddUpdateAndDeleteNFTResults() throws {
        let firstCollection = NFTCollection(
            id: "1",
            name: "First Collection",
            description: "Description of the first collection",
            chain: .ethereum,
            contractAddress: "0x123",
            image: NFTImage(imageUrl: "url1", previewImageUrl: "url2", originalSourceUrl: "url3"),
            isVerified: true
        )
        let firstAsset = NFTAsset(
            id: "1",
            collectionId: "1",
            tokenId: "1",
            tokenType: .erc721,
            name: "First Asset",
            description: "Description of the first asset",
            chain: .ethereum,
            image: NFTImage(imageUrl: "url4", previewImageUrl: "url5", originalSourceUrl: "url6"),
            attributes: [
                NFTAttribute(name: "Color", value: "Red"),
                NFTAttribute(name: "Size", value: "Large")
            ]
        )

        let secondCollection = NFTCollection(
            id: "2",
            name: "Second Collection",
            description: "Description of the second collection",
            chain: .ethereum,
            contractAddress: "0x456",
            image: NFTImage(imageUrl: "url7", previewImageUrl: "url8", originalSourceUrl: "url9"),
            isVerified: true
        )
        let secondAsset = NFTAsset(
            id: "2",
            collectionId: "2",
            tokenId: "2",
            tokenType: .erc1155,
            name: "Second Asset",
            description: "Description of the second asset",
            chain: .ethereum,
            image: NFTImage(imageUrl: "url10", previewImageUrl: "url11", originalSourceUrl: "url12"),
            attributes: [
                NFTAttribute(name: "Color", value: "Blue"),
                NFTAttribute(name: "Shape", value: "Square")
            ]
        )

        let initialData = [
            NFTData(collection: firstCollection, assets: [firstAsset]),
            NFTData(collection: secondCollection, assets: [secondAsset])
        ]
        try nftStore.saveNFTData(initialData, for: "wallet1")

        var results = try nftStore.getNFTResults(for: "wallet1")
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first?.collection.id, "1")
        XCTAssertEqual(results.last?.collection.id, "2")

        let updatedData = [NFTData(collection: firstCollection, assets: [firstAsset])]
        try nftStore.saveNFTData(updatedData, for: "wallet1")

        results = try nftStore.getNFTResults(for: "wallet1")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.collection.id, "1")

        XCTAssertEqual(results.first?.assets.first?.attributes.count, 2)
        XCTAssertEqual(results.first?.assets.first?.attributes.first?.name, "Color")
    }
    
    func testVerifyAllElementsRemoved() throws {
        let collection = NFTCollection(
            id: "1",
            name: "Test Collection",
            description: "A test NFT collection",
            chain: .ethereum,
            contractAddress: "0x123",
            image: NFTImage(imageUrl: "url1", previewImageUrl: "url2", originalSourceUrl: "url3"),
            isVerified: true
        )
        let asset = NFTAsset(
            id: "1",
            collectionId: "1",
            tokenId: "1",
            tokenType: .erc721,
            name: "Test Asset",
            description: "A test NFT asset",
            chain: .ethereum,
            image: NFTImage(imageUrl: "url4", previewImageUrl: "url5", originalSourceUrl: "url6"),
            attributes: [
                NFTAttribute(name: "Color", value: "Blue"),
                NFTAttribute(name: "Size", value: "Large")
            ]
        )
        let data = [NFTData(collection: collection, assets: [asset])]

        try nftStore.saveNFTData(data, for: "wallet1")
        try nftStore.saveNFTData([], for: "wallet1")
        
        let existCollection = try db.dbQueue.read { db in
            try NFTCollectionRecord.fetchAll(db)
        }
        
        let existCollectionImage = try db.dbQueue.read { db in
            try NFTCollectionImageRecord.fetchAll(db)
        }
        
        let existNFTAsset = try db.dbQueue.read { db in
            try NFTAssetRecord.fetchAll(db)
        }
        
        let existNFTImage = try db.dbQueue.read { db in
            try NFTImageRecord.fetchAll(db)
        }
        
        let existNFTAttribute = try db.dbQueue.read { db in
            try NFTAttributeRecord.fetchAll(db)
        }
        
        XCTAssertTrue(existCollection.isEmpty)
        XCTAssertTrue(existCollectionImage.isEmpty)
        XCTAssertTrue(existNFTAsset.isEmpty)
        XCTAssertTrue(existNFTImage.isEmpty)
        XCTAssertTrue(existNFTAttribute.isEmpty)
    }
}
