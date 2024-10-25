// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct BannersRequest: ValueObservationQueryable {
    public static var defaultValue: [Banner] { [] }

    private let walletId: String?
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
            .filter(events.map { $0.rawValue }.contains(Columns.Banner.event))
            .filter(Columns.Banner.state != BannerState.cancelled.rawValue)
            .asRequest(of: BannerInfo.self)
        
        if let walletId {
            query = query.filter(Columns.Banner.walletId == walletId)
        }
        if let assetId, let chain {
            query = query.filter(Columns.Banner.assetId == assetId || Columns.Banner.chain == chain)
        } else if let assetId {
            query = query.filter(Columns.Banner.assetId == assetId)
        } else if let chain {
            query = query.filter(Columns.Banner.chain == chain)
        }
        
        return try query
            .fetchAll(db)
            .compactMap { $0.mapToBanner() }
    }
}
