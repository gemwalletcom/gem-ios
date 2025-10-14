// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization
import Components

public struct TransactionNetworkFeeViewModel {
    private let feeDisplay: AmountDisplay?
    private let onInfoAction: VoidAction

    public init(
        feeDisplay: AmountDisplay?,
        onInfoAction: VoidAction = nil
    ) {
        self.feeDisplay = feeDisplay
        self.onInfoAction = onInfoAction
    }
}

// MARK: - ItemModelProvidable

extension TransactionNetworkFeeViewModel: ItemModelProvidable {
    public var itemModel: TransactionItemModel {
        .fee(
            ListItemModel(
                title: Localized.Transfer.networkFee,
                subtitle: feeDisplay?.fiat?.text ?? feeDisplay?.amount.text ?? "-",
                subtitleExtra: nil,
                infoAction: onInfoAction
            )
        )
    }
}
