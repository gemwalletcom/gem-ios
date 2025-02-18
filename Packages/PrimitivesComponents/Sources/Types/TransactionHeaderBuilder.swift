// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives

public struct TransactionHeaderTypeBuilder {
    public static func build(
        infoModel: TransactionInfoViewModel,
        type: TransactionType,
        swapContext: TransactionHeaderInputType.SwapContext?
    ) -> TransactionHeaderType {
        let inputType: TransactionHeaderInputType = {
            switch type {
            case .transfer,
                    .tokenApproval,
                    .stakeDelegate,
                    .stakeUndelegate,
                    .stakeRedelegate,
                    .stakeRewards,
                    .stakeWithdraw,
                    .assetActivation,
                    .transferNFT,
                    .smartContractCall:
                return .amount(showFiatSubtitle: true)
            case .swap:
                guard let swapContext = swapContext else {
                    fatalError("Swap context missed")
                }
                guard let metadata = swapContext.swapMetadata else {
                    fatalError("Swap metadata missed")
                }
                return .swap(metadata)
            }
        }()
        return infoModel.headerType(input: inputType)
    }
    
    public static func build(
        infoModel: TransactionInfoViewModel,
        dataType: TransferDataType,
        metadata: TransferDataMetadata?
    ) -> TransactionHeaderType {
        let inputType: TransactionHeaderInputType = {
            switch dataType {
            case .transfer,
                    .generic,
                    .stake,
                    .tokenApprove:
                return .amount(
                    showFiatSubtitle: true
                )
            case .transferNft(let asset):
                return .nft(asset)
            case .account(_, let type):
                switch type {
                case .activate:
                    return .amount(
                        showFiatSubtitle: false
                    )
                }
            case .swap(let fromAsset, let toAsset, let quote, _):
                let context = TransactionHeaderInputType.SwapContext(
                    assets: [fromAsset, toAsset],
                    prices: metadata?.assetPrices ?? [:],
                    metadata: TransactionSwapMetadata(
                        fromAsset: fromAsset.id,
                        fromValue: quote.fromValue,
                        toAsset: toAsset.id,
                        toValue: quote.toValue
                    )
                )
                guard let metadata = context.swapMetadata else {
                    fatalError("Swap metadata missed")
                }
                return .swap(metadata)
            }
        }()
        return infoModel.headerType(input: inputType)
    }
}
