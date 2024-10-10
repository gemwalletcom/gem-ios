// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives
import BigInt

public struct AssetDetailsRecord: Codable, FetchableRecord, PersistableRecord  {
    
    public static let databaseTableName: String = "assets_details"
    
    public var assetId: String
    
    public var homepage: String?
    public var explorer: String?
    public var twitter: String?
    public var telegram: String?
    public var github: String?
    public var youtube: String?
    public var facebook: String?
    public var reddit: String?
    public var coingecko: String?
    public var coinmarketcap: String?
    public var discord: String?
    
    public var marketCap: Double?
    public var marketCapRank: Int?
    public var totalVolume: Double?
    public var circulatingSupply: Double?
    public var totalSupply: Double?
    public var maxSupply: Double?
    
    public var stakingApr: Double?
}

extension AssetDetailsRecord: Identifiable {
    public var id: String { assetId }
}

extension AssetDetailsRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column("assetId", .text)
                .primaryKey()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            
            $0.column("homepage", .text)
            $0.column("explorer", .text)
            $0.column("twitter", .text)
            $0.column("telegram", .text)
            $0.column("github", .text)
            $0.column("youtube", .text)
            $0.column("facebook", .text)
            $0.column("reddit", .text)
            $0.column("coingecko", .text)
            $0.column("coinmarketcap", .text)
            $0.column("discord", .text)
            
            $0.column("marketCap", .double)
            $0.column("marketCapRank", .integer)
            $0.column("totalVolume", .double)
            $0.column("circulatingSupply", .double)
            $0.column("totalSupply", .double)
            $0.column("maxSupply", .double)
            
            $0.column("stakingApr", .double)
        }
    }
}

extension AssetDetailsRecord {
    func mapToAssetDetailsInfo(asset: AssetRecord) -> AssetDetailsInfo {
        let details = AssetDetails(
            links: AssetLinks(
                homepage: homepage,
                explorer: explorer,
                twitter: twitter,
                telegram: telegram,
                github: github,
                youtube: youtube,
                facebook: facebook,
                reddit: reddit,
                coingecko: coingecko,
                coinmarketcap: coinmarketcap,
                discord: discord
            ),
            isBuyable: asset.isBuyable,
            isSellable: false,
            isSwapable: asset.isStakeable,
            isStakeable: asset.isSwappable,
            stakingApr: stakingApr
        )
        return AssetDetailsInfo(
            details: details,
            market: market
        )
    }
    
    var market: AssetMarket {
        AssetMarket(
            marketCap: marketCap,
            marketCapRank: marketCapRank?.asInt32,
            totalVolume: totalVolume,
            circulatingSupply: circulatingSupply,
            totalSupply: totalSupply,
            maxSupply: maxSupply
        )
    }
}

extension AssetFull {
    var record: AssetDetailsRecord {
        return AssetDetailsRecord(
            assetId: asset.id.identifier,
            homepage: details?.links.homepage,
            explorer: details?.links.explorer,
            twitter: details?.links.twitter,
            telegram: details?.links.telegram,
            github: details?.links.github,
            youtube: details?.links.youtube,
            facebook: details?.links.facebook,
            reddit: details?.links.reddit,
            coingecko: details?.links.coingecko,
            coinmarketcap: details?.links.coinmarketcap,
            discord: details?.links.discord,
            marketCap: market?.marketCap,
            marketCapRank: market?.marketCapRank?.asInt,
            totalVolume: market?.totalVolume,
            circulatingSupply: market?.circulatingSupply,
            totalSupply: market?.totalSupply,
            maxSupply: market?.maxSupply,
            stakingApr: details?.stakingApr
        )
    }
}
