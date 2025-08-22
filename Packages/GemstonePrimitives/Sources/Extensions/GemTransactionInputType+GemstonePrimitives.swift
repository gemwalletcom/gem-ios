// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemTransactionInputType {
    public func getAsset() -> GemAsset {
        switch self {
        case .transfer(let asset):
            return asset
        case .swap(let fromAsset, _):
            return fromAsset
        case .stake(let asset, _):
            return asset
        }
    }
}

extension GemTransactionInputType {
    public func map() throws -> TransferDataType {
        switch self {
        case .transfer(let gemAsset):
            return TransferDataType.transfer(try gemAsset.map())
        case .swap(let fromAsset, let toAsset):
            // For mapping purposes, create a placeholder SwapData - in real usage this would contain actual swap information
            let swapQuoteData = SwapQuoteData(to: "", value: "", data: "", approval: nil, gasLimit: nil)
            let providerData = SwapProviderData(provider: .uniswapV4, name: "", protocolName: "")
            let swapQuote = SwapQuote(fromValue: "0", toValue: "0", providerData: providerData, walletAddress: "", slippageBps: 0, etaInSeconds: nil)
            let swapData = SwapData(quote: swapQuote, data: swapQuoteData)
            return TransferDataType.swap(try fromAsset.map(), try toAsset.map(), swapData)
        case .stake(let asset, let operation):
            let asset = try asset.map()
            return TransferDataType.stake(asset, try operation.mapToStakeType(asset: asset))
        }
    }
}

extension TransferDataType {
    public func map() -> GemTransactionInputType {
        switch self {
        case .transfer(let asset):
            return .transfer(asset: asset.map())
        case .swap(let fromAsset, let toAsset, _):
            return .swap(fromAsset: fromAsset.map(), toAsset: toAsset.map())
        case .stake(let asset, let stakeType):
            return .stake(asset: asset.map(), stakeType: stakeType.map())
        case .deposit, .withdrawal, .transferNft, .tokenApprove, .account, .perpetual, .generic:
            fatalError("Unsupported transaction type: \(self)")
        }
    }
}
