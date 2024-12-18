// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum SelectAssetType: Identifiable, Hashable {
    case send
    case receive
    case buy
    case sell
    case swap(SelectAssetSwapType)
    case stake
    case manage
    case priceAlert

    public var id: String {
        switch self {
        case .send: "send"
        case .receive: "receive"
        case .buy: "buy"
        case .sell: "sell"
        case .swap(let type): "swap_\(type.id)"
        case .stake: "stake"
        case .manage: "manage"
        case .priceAlert:"priceAlert"
        }
    }
}

public enum SelectAssetSwapType: Identifiable, Hashable {
    case pay
    case receive(chains: [Chain], assetIds: [AssetId])
    
    public var id: String {
        return "rawValue" //FIX
    }
}
