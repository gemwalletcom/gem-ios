// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Style
import Localization
import Primitives

public struct TransactionNetworkFeeItemModel: ListItemViewable {
    private let feeAmount: String
    private let feeFiat: String?
    private let onInfoAction: (() -> Void)?
    
    public init(
        feeAmount: String,
        feeFiat: String?,
        onInfoAction: (() -> Void)? = nil
    ) {
        self.feeAmount = feeAmount
        self.feeFiat = feeFiat
        self.onInfoAction = onInfoAction
    }
    
    public var listItemModel: ListItemType {
        .custom(
            ListItemConfiguration(
                title: Localized.Transfer.networkFee,
                subtitle: feeAmount,
                subtitleExtra: feeFiat,
                infoAction: onInfoAction
            )
        )
    }
}