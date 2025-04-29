// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct BannersRequest: ValueObservationQueryable {
    public static var defaultValue: [Banner] { [] }

    public var walletId: String?
    
    private let assetId: String?
    private let chain: String?
    private let events: [BannerEvent]

    public init(
        walletId: String?,
        assetId: String?,
        chain: String?,
        events: [BannerEvent]
    ) {
        self.walletId = walletId
        self.assetId = assetId
        self.chain = chain
        self.events = events
    }

    public func fetch(_ db: Database) throws -> [Banner] {
        var query = BannerRecord
            .including(optional: BannerRecord.asset)
            .including(optional: BannerRecord.chain)
            .including(optional: BannerRecord.wallet)
            .filter(events.map { $0.rawValue }.contains(BannerRecord.Columns.event))
            .filter(BannerRecord.Columns.state != BannerState.cancelled.rawValue)
            .asRequest(of: BannerInfo.self)
        
        if let walletId {
            query = query.filter(BannerRecord.Columns.walletId == walletId || BannerRecord.Columns.walletId == nil)
        }
        if let assetId, let chain {
            query = query.filter(BannerRecord.Columns.assetId == assetId || BannerRecord.Columns.chain == chain)
        } else if let assetId {
            query = query.filter(BannerRecord.Columns.assetId == assetId)
        } else if let chain {
            query = query.filter(BannerRecord.Columns.chain == chain)
        }
        
        return try query
            .fetchAll(db)
            .compactMap { $0.mapToBanner() }
    }
}
