// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Blockchain
import BigInt
import Primitives
import PrimitivesComponents
import Preferences

struct TransactionInputViewModel {
    let data: TransferData
    let input: TransactionLoad?
    let metaData: TransferDataMetadata?
    let transferAmountResult: TransferAmountResult?

    private let preferences: Preferences

    init(
        data: TransferData,
        input: TransactionLoad?,
        metaData: TransferDataMetadata?,
        transferAmountResult: TransferAmountResult?,
        preferences: Preferences = Preferences.standard
    ) {
        self.input = input
        self.data = data
        self.metaData = metaData
        self.transferAmountResult = transferAmountResult
        self.preferences = preferences
    }

    var value: BigInt {
        switch transferAmountResult {
        case .amount(let amount): amount.value
        case .error(let amount, _): amount.value
        case .none: data.value
        }
    }
    
    var feeValue: BigInt? {
        switch transferAmountResult {
        case .amount(let amount): amount.networkFee
        case .error(let amount, _): amount.networkFee
        case .none: .none
        }
    }

    var infoModel: TransactionInfoViewModel {
        TransactionInfoViewModel(
            currency: preferences.currency,
            asset: data.type.asset,
            assetPrice: metaData?.assetPrice,
            feeAsset: data.type.asset.feeAsset,
            feeAssetPrice: metaData?.feePrice,
            value: value,
            feeValue: feeValue
        )
    }

    var amountText: String {
        infoModel.amountValueText
    }
    
    var amountSecondText: String {
        infoModel.amountFiatValueText ?? .empty
    }
    
    var networkFeeText: String? {
        infoModel.feeValueText
    }
    
    var networkFeeFiatText: String? {
        infoModel.feeFiatValueText
    }
    
    var headerType: TransactionHeaderType {
        let inputType: TransacitonHeaderInputType = {
            switch data.type {
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
                return .swap(
                    .init(
                        fromAsset: fromAsset,
                        fromValue: BigInt(stringLiteral: quote.fromValue),
                        fromPrice: metaData?.assetPrices[fromAsset.id.identifier],
                        toAsset: toAsset,
                        toValue: BigInt(stringLiteral: quote.toValue),
                        toPrice: metaData?.assetPrices[toAsset.id.identifier]
                    )
                )
            }
        }()
        return infoModel.headerType(input: inputType)
    }
}
