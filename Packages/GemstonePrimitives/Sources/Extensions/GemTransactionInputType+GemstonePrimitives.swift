// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import BigInt

extension GemTransactionInputType {
    public func getAsset() -> GemAsset {
        switch self {
        case .transfer(let asset): asset
        case .deposit(let asset): asset
        case .swap(let fromAsset, _, _): fromAsset
        case .stake(let asset, _): asset
        case .tokenApprove(let asset, _): asset
        case .generic(let asset, _, _): asset
        case .perpetual(asset: let asset, perpetualType: _): asset
        }
    }
}

extension GemTransactionInputType {
    public func map() throws -> TransferDataType {
        switch self {
        case .transfer(let asset):
            return TransferDataType.transfer(try asset.map())
        case .deposit(let asset):
            return TransferDataType.deposit(try asset.map())
        case .swap(let fromAsset, let toAsset, let gemSwapData):
            return TransferDataType.swap(try fromAsset.map(), try toAsset.map(), try gemSwapData.map())
        case .stake(let asset, let type):
            return TransferDataType.stake(try asset.map(), try type.map())
        case .tokenApprove(let asset, let approvalData):
            return TransferDataType.tokenApprove(try asset.map(), approvalData.map())
        case .generic(let asset, let metadata, let extra):
            return TransferDataType.generic(asset: try asset.map(), metadata: metadata.map(), extra: try extra.map())
        case .perpetual(asset: let asset, perpetualType: let perpetualType):
            return TransferDataType.perpetual(try asset.map(), try perpetualType.map())
        }
    }
}

extension TransferDataType {
    public func map() -> GemTransactionInputType {
        switch self {
        case .transfer(let asset):
            return .transfer(asset: asset.map())
        case .deposit(let asset):
            return .deposit(asset: asset.map())
        case .swap(let fromAsset, let toAsset, let swapData):
            return .swap(fromAsset: fromAsset.map(), toAsset: toAsset.map(), swapData: swapData.map())
        case .stake(let asset, let stakeType):
            return .stake(asset: asset.map(), stakeType: stakeType.map())
        case .tokenApprove(let asset, let approvalData):
            return .tokenApprove(asset: asset.map(), approvalData: approvalData.map())
        case .generic(let asset, let metadata, let extra):
            return .generic(asset: asset.map(), metadata: metadata.map(), extra: extra.map())
        case .withdrawal, .transferNft, .account:
            fatalError("Unsupported transaction type: \(self)")
        case .perpetual(let asset, let perpetualType):
            return .perpetual(asset: asset.map(), perpetualType: perpetualType.map())
        }
    }
}
