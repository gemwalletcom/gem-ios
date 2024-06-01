// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives
import BigInt

public struct AssetDetailsRecord: Codable, FetchableRecord, PersistableRecord  {
    
    public static var databaseTableName: String = "assets_details"
    
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
        try db.create(table: Self.databaseTableName) { t in
            t.column("assetId", .text)
                .primaryKey()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            
            t.column("homepage", .text)
            t.column("explorer", .text)
            t.column("twitter", .text)
            t.column("telegram", .text)
            t.column("github", .text)
            t.column("youtube", .text)
            t.column("facebook", .text)
            t.column("reddit", .text)
            t.column("coingecko", .text)
            t.column("coinmarketcap", .text)
            t.column("discord", .text)
            
            t.column("marketCap", .double)
            t.column("marketCapRank", .integer)
            t.column("totalVolume", .double)
            t.column("circulatingSupply", .double)
            t.column("totalSupply", .double)
            t.column("maxSupply", .double)
            
            t.column("stakingApr", .double)
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
