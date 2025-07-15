// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives

public struct TransactionHeaderTypeBuilder {
    public static func build(
        infoModel: TransactionInfoViewModel,
        transaction: Transaction,
        swapMetadata: SwapMetadata?
    ) -> TransactionHeaderType {
        let inputType: TransactionHeaderInputType = {
            switch transaction.type {
            case .transfer,
                    .stakeDelegate,
                    .stakeUndelegate,
                    .stakeRedelegate,
                    .stakeRewards,
                    .stakeWithdraw,
                    .smartContractCall:
                return .amount(showFiatSubtitle: true)
            case .swap:
                guard let swapMetadata, let input = SwapMetadataViewModel(metadata: swapMetadata).headerInput else {
                    fatalError("swapMetadata is missed")
                }
                return .swap(input)
            case .assetActivation:
                return .symbol
            case .tokenApproval:
                if infoModel.isZero {
                    return .amount(showFiatSubtitle: false)
                } else {
                    return .symbol
                }
            case .transferNFT:
                guard let metadata = transaction.metadata, case .nft(let metadata) = metadata else {
                    return .amount(showFiatSubtitle: false)
                }
                return .nft(name: metadata.name, id: metadata.assetId)
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
                return .nft(name: asset.name, id: asset.id)
            case .account(_, let type):
                switch type {
                case .activate:
                    return .amount(
                        showFiatSubtitle: false
                    )
                }
            case .swap(let fromAsset, let toAsset, let data):
                let assetPrices = (metadata?.assetPrices ?? [:]).map { (assetId, price) in
                    price.mapToAssetPrice(assetId: assetId)
                }
                
                let model = SwapMetadataViewModel(
                    metadata: SwapMetadata(
                        assets: [fromAsset, toAsset],
                        assetPrices: assetPrices,
                        transactionMetadata: TransactionSwapMetadata(
                            fromAsset: fromAsset.id,
                            fromValue: data.quote.fromValue,
                            toAsset: toAsset.id,
                            toValue: data.quote.toValue,
                            provider: data.quote.providerData.provider.rawValue
                        )
                    )
                )

                guard let input = model.headerInput else {
                    fatalError("fromAsset & toAsset missed")
                }
                return .swap(input)
            }
        }()
        return infoModel.headerType(input: inputType)
    }
}
