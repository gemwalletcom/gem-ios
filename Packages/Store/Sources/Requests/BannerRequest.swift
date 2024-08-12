// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct BannersRequest: Queryable {
    public static var defaultValue: [Banner] { [] }

    let assetId: String?

    public init(
        assetId: String?
    ) {
        self.assetId = assetId
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
            .filter(Columns.Banner.assetId == assetId)
            //.filter([BannerState.cancelled].contains(Columns.Banner.state))
            .filter(Columns.Banner.state != BannerState.cancelled.rawValue)
            .asRequest(of: BannerInfo.self)
            .fetchAll(db)
            .compactMap { $0.mapToBanner() }
    }
}
