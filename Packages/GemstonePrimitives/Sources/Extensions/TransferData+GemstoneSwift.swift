// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension TransferData {
    public var asset: Asset {
        switch type {
        case .transfer(let asset): asset
        case .transferNft(let asset): asset.chain.asset
        case .swap(let asset, _, _): asset
        case .stake(let asset, _): asset
        case .account(let asset, _): asset
        case .generic(let asset, _, _): asset
        }
    }
}
