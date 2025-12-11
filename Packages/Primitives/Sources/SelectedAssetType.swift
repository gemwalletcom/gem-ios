// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum SelectedAssetType: Sendable, Hashable, Identifiable {
    case send(RecipientAssetType)
    case receive(ReceiveAssetType)
    case stake(Asset)
    case buy(Asset)
    case sell(Asset)
    case swap(Asset, Asset?)

    public var id: String {
        switch self {
        case .send(let type): "send_\(type.id)"
        case .receive(let type): "receive_\(type.id)"
        case .stake(let asset): "stake_\(asset.id)"
        case .buy(let asset): "buy_\(asset.id)"
        case .sell(let asset): "sell_\(asset.id)"
        case .swap(let fromAsset, let toAsset): "swap_\(fromAsset.id)_\(toAsset?.id.identifier ?? "")"
        }
    }
}

public extension SelectedAssetType {
    func recentActivityData(assetId: AssetId) -> RecentActivityData? {
        switch self {
        case .receive: RecentActivityData(type: .receive, assetId: assetId, toAssetId: nil)
        case .buy: RecentActivityData(type: .fiatBuy, assetId: assetId, toAssetId: nil)
        case .sell: RecentActivityData(type: .fiatSell, assetId: assetId, toAssetId: nil)
        case .send, .stake, .swap: .none
        }
    }
}
