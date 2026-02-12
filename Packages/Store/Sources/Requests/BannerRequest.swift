// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct BannersRequest: DatabaseQueryable {

    public var walletId: WalletId?

    private let assetId: AssetId?
    private let chain: Chain?
    private let events: [BannerEvent]

    public init(
        walletId: WalletId?,
        assetId: AssetId?,
        chain: Chain?,
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
            query = query.filter(BannerRecord.Columns.walletId == walletId.id || BannerRecord.Columns.walletId == nil)
        }
        if let assetId, let chain {
            query = query.filter(BannerRecord.Columns.assetId == assetId.identifier || BannerRecord.Columns.chain == chain.rawValue)
        } else if let assetId {
            query = query.filter(BannerRecord.Columns.assetId == assetId.identifier)
        } else if let chain {
            query = query.filter(BannerRecord.Columns.chain == chain.rawValue)
        }

        return try query
            .fetchAll(db)
            .compactMap { $0.mapToBanner() }
    }
}

extension BannersRequest: Equatable {}
