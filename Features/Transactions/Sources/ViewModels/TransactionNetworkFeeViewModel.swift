// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Localization
import Components

public struct TransactionNetworkFeeViewModel: Sendable {
    private let feeDisplay: AmountDisplay?
    private let onInfoAction: (@MainActor @Sendable() -> Void)?

    public init(
        feeDisplay: AmountDisplay?,
        onInfoAction: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.feeDisplay = feeDisplay
        self.onInfoAction = onInfoAction
    }
    public var itemModel: TransactionItemModel {
        .listItem(
            .custom(
                ListItemConfiguration(
                    title: Localized.Transfer.networkFee,
                    subtitle: feeDisplay?.amount.text ?? "-",
                    subtitleExtra: feeDisplay?.fiat?.text,
                    infoAction: onInfoAction
                )
            )
        )
    }
}
