// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension PerpetualMarginType {
    public init(id: String) throws {
        if let type = PerpetualMarginType(rawValue: id) {
            self = type
        } else {
            throw AnyError("invalid margin type: \(id)")
        }
    }
}

extension PerpetualDirection {
    public init(id: String) throws {
        if let direction = PerpetualDirection(rawValue: id) {
            self = direction
        } else {
            throw AnyError("invalid direction: \(id)")
        }
    }
}

extension Perpetual {
    public var coin: String {
        assetId.tokenId?.components(separatedBy: AssetId.subTokenSeparator).last ?? name
    }

    public var marginType: PerpetualMarginType { onlyIsolated ? .isolated : .cross }
}

extension PerpetualSearchData {
    public var assetBasic: AssetBasic {
        AssetBasic(
            asset: asset,
            properties: AssetProperties(
                isEnabled: false,
                isBuyable: false,
                isSellable: false,
                isSwapable: false,
                isStakeable: false,
                stakingApr: nil,
                isEarnable: false,
                earnApr: nil,
                hasImage: false
            ),
            score: AssetScore(rank: 0),
            price: nil
        )
    }
}
