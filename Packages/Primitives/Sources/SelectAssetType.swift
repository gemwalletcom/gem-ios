// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum SelectAssetType: Identifiable, Hashable {
    case send
    case receive(ReceiveAssetType)
    case buy
    case swap(SelectAssetSwapType)
    case stake
    case manage
    case priceAlert

    public var id: String {
        switch self {
        case .send: "send"
        case .receive(let type): "receive_\(type.id)"
        case .buy: "buy"
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

public enum ReceiveAssetType: String, Hashable, Identifiable {
    case regular
    case collections

    public var id: String {
        rawValue
    }
}
