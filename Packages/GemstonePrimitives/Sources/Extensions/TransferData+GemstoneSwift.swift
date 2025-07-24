// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension TransferDataType {
    public var asset: Asset {
        switch self {
        case .transfer(let asset),
            .deposit(let asset),
            .swap(let asset, _, _),
            .tokenApprove(let asset, _),
            .stake(let asset, _),
            .account(let asset, _),
            .generic(let asset, _, _): asset
        case .transferNft(let asset): asset.chain.asset
        }
    }
}
