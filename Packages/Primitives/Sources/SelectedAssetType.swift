// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum SelectedAssetType: Sendable, Hashable {
    case send(RecipientAssetType)
    case receive(ReceiveAssetType)
    case stake(Asset)
    case buy(Asset)
    case sell(Asset)
    case swap(Asset, Asset?)
}

extension SelectedAssetType: Identifiable {
    public var id: String {
        switch self {
        case .send(let type): "send_\(type.id)"
        case .receive(let type): "receive_\(type.id)"
        case .stake: "stake"
        case .buy: "buy"
        case .sell: "sell"
        case .swap: "swap"
        }
    }
}
