// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Blockchain
import BigInt
import Primitives
import PrimitivesComponents
import Preferences

struct TransactionInputViewModel {
    let data: TransferData
    let transactionData: TransactionData?
    let metaData: TransferDataMetadata?
    let transferAmountResult: TransferAmountResult?

    private let preferences: Preferences

    init(
        data: TransferData,
        transactionData: TransactionData?,
        metaData: TransferDataMetadata?,
        transferAmountResult: TransferAmountResult?,
        preferences: Preferences = Preferences.standard
    ) {
        self.transactionData = transactionData
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
            feeValue: transactionData?.fee.fee,
            direction: nil
        )
    }
    
    var networkFeeText: String? {
        infoModel.feeValueText
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
