// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Blockchain
import BigInt
import Primitives
import PrimitivesComponents
import Preferences

struct TransactionInputViewModel: Sendable {
    let data: TransferData
    let transactionData: TransactionData?
    let metaData: TransferDataMetadata?
    let transferAmount: TransferAmountValidation?

    private let preferences: Preferences

    init(
        data: TransferData,
        transactionData: TransactionData?,
        metaData: TransferDataMetadata?,
        transferAmount: TransferAmountValidation?,
        preferences: Preferences = Preferences.standard
    ) {
        self.transactionData = transactionData
        self.data = data
        self.metaData = metaData
        self.transferAmount = transferAmount
        self.preferences = preferences
    }

    var value: BigInt {
        switch transferAmount {
        case .success(let amount): amount.value
        case .failure, .none: data.value
        }
    }
    
    var asset: Asset {
        switch data.type {
        case .perpetual(_, let type): type.baseAsset
        default: data.type.asset
        }
    }

    var infoModel: TransactionInfoViewModel {
        TransactionInfoViewModel(
            currency: preferences.currency,
            asset: asset,
            assetPrice: metaData?.assetPrice,
            feeAsset: data.type.asset.feeAsset,
            feeAssetPrice: metaData?.feePrice,
            value: value,
            feeValue: transactionData?.fee.fee,
            direction: nil
        )
    }
    
    var networkFeeText: String? { infoModel.feeDisplay?.amount.text ?? "-" }
    var networkFeeFiatText: String? { infoModel.feeDisplay?.fiat?.text }
    
    var headerType: TransactionHeaderType {
        TransactionHeaderTypeBuilder.build(
            infoModel: infoModel,
            dataType: data.type,
            metadata: metaData
        )
    }
    
    var isReady: Bool {
        if case .success = self.transferAmount {
            return true
        }
        return false
    }
}
