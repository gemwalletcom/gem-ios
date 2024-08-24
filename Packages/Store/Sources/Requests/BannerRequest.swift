// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct BannersRequest: Queryable {
    public static var defaultValue: [Banner] { [] }

    let walletId: String?
    let assetId: String?
    let events: [BannerEvent]

    public init(
        walletId: String?,
        assetId: String?,
        events: [BannerEvent]
    ) {
        self.walletId = walletId
        self.assetId = assetId
        self.events = events
    }

    public func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[Banner], Error> {
        ValueObservation
            .tracking { db in try fetch(db) }
            .publisher(in: dbQueue, scheduling: .immediate)
            .map { $0.map{ $0 } }
            .eraseToAnyPublisher()
    }

    private func fetch(_ db: Database) throws -> [Banner] {
        return try BannerRecord
            .including(optional: BannerRecord.asset)
            .including(optional: BannerRecord.wallet)
            .filter(Columns.Banner.walletId == walletId || Columns.Banner.walletId == nil)
            .filter(Columns.Banner.assetId == assetId || Columns.Banner.assetId == nil)
            .filter(events.map { $0.rawValue }.contains(Columns.Banner.event))
            .filter(Columns.Banner.state != BannerState.cancelled.rawValue)
            .asRequest(of: BannerInfo.self)
            .fetchAll(db)
            .compactMap { $0.mapToBanner() }

    }
}
