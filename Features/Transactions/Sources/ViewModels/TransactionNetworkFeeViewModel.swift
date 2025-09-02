// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization

public struct TransactionNetworkFeeViewModel: Sendable {
    private let feeAmount: String
    private let feeFiat: String?
    private let onInfoAction: (@MainActor @Sendable() -> Void)?
    
    public init(
        feeAmount: String,
        feeFiat: String?,
        onInfoAction: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.feeAmount = feeAmount
        self.feeFiat = feeFiat
        self.onInfoAction = onInfoAction
    }
    
    public var itemModel: TransactionNetworkFeeItemModel {
        TransactionNetworkFeeItemModel(
            title: Localized.Transfer.networkFee,
            subtitle: feeAmount,
            subtitleExtra: feeFiat,
            infoAction: onInfoAction
        )
    }
}
