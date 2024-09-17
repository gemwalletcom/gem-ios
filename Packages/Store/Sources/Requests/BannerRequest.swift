// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
@preconcurrency import Primitives // TODO: - integrate Sendable for BannerEvent

public struct BannersRequest: ValueObservationQueryable {
    public static var defaultValue: [Banner] { [] }

    private let walletId: String?
    private let assetId: String?
    private let events: [BannerEvent]

    public init(
        walletId: String?,
        assetId: String?,
        events: [BannerEvent]
    ) {
        self.walletId = walletId
        self.assetId = assetId
        self.events = events
    }

    public func fetch(_ db: Database) throws -> [Banner] {
        try BannerRecord
            .including(optional: BannerRecord.asset)
            .including(optional: BannerRecord.wallet)
            .filter(Columns.Banner.walletId == walletId || Columns.Banner.walletId == nil)
            .filter(Columns.Banner.assetId == assetId)
            .filter(events.map { $0.rawValue }.contains(Columns.Banner.event))
            .filter(Columns.Banner.state != BannerState.cancelled.rawValue)
            .asRequest(of: BannerInfo.self)
            .fetchAll(db)
            .compactMap { $0.mapToBanner() }

    }
}
