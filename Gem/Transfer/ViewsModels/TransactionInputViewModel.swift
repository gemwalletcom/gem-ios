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
        case .error, nil: data.value
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
            feeValue: input?.fee.fee
        )
    }

    var amountText: String {
        infoModel.amountValueText
    }
    
    var amountSecondText: String {
        infoModel.amountFiatValueText ?? .empty
    }
    
    var networkFeeText: String? {
        switch transferAmountResult {
        case .amount: infoModel.feeValueText
        case .error, nil: "-"
        }
    }
    
    var networkFeeFiatText: String? {
        infoModel.feeFiatValueText
    }
    
    var headerType: TransactionHeaderType {
        TransactionHeaderTypeBuilder.build(
            infoModel: infoModel,
            dataType: data.type,
            metadata: metaData
        )
    }
}
