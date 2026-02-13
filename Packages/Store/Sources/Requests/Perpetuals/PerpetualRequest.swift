// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct PerpetualRequest: DatabaseQueryable {

    public let assetId: AssetId

    public init(assetId: AssetId) {
        self.assetId = assetId
    }

    public func fetch(_ db: Database) throws -> PerpetualData {
        let result = try PerpetualRecord
            .including(required: PerpetualRecord.asset)
            .filter(PerpetualRecord.Columns.assetId == assetId.identifier)
            .asRequest(of: PerpetualInfo.self)
            .fetchOne(db)?
            .mapToPerpetualData()

        return result ?? .empty
    }
}

// MARK: - Models Extensions

extension PerpetualRequest: Equatable {}

extension PerpetualData {
    public static var empty: PerpetualData {
        PerpetualData(
            perpetual: Perpetual(
                id: "",
                name: "",
                provider: .hypercore,
                assetId: AssetId(chain: .bitcoin, tokenId: nil),
                identifier: "",
                price: .zero,
                pricePercentChange24h: .zero,
                openInterest: .zero,
                volume24h: .zero,
                funding: .zero,
                maxLeverage: 1
            ),
            asset: Asset(id: .init(chain: .bitcoin, tokenId: .none), name: "", symbol: "", decimals: 0, type: .native),
            metadata: PerpetualMetadata(isPinned: false)
        )
    }
}
