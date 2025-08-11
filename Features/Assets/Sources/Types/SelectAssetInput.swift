// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct SelectAssetInput: Hashable {
    public let type: SelectAssetType
    public let assetAddress: AssetAddress

    public init(type: SelectAssetType, assetAddress: AssetAddress) {
        self.type = type
        self.assetAddress = assetAddress
    }
}

extension SelectAssetInput: Identifiable {
    public var id: String { type.id }

    public var asset: Asset  { assetAddress.asset }
    public var address: String { assetAddress.address }
    public var fiatType: FiatQuoteType  {
        switch type {
        case .send, .receive, .swap, .manage, .priceAlert, .deposit, .withdraw:
            fatalError("fiat operations not supported")
        case .buy: .buy
        }
    }
}
