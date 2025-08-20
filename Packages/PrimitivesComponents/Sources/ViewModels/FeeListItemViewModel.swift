// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

public struct FeeListItemViewModel: ListItemViewModelRepresentable {
    public let value: String?
    public let fiat: String?
    public let onInfo: VoidAction
    public let onSelect: VoidAction
    
    public init(
        feeDisplay: AmountDisplay?,
        onInfo: VoidAction = nil,
        onSelect: VoidAction = nil
    ) {
        self.value = feeDisplay?.amount.text
        self.fiat = feeDisplay?.fiat?.text
        self.onInfo = onInfo
        self.onSelect = onSelect
    }
    
    public init(
        value: String?,
        fiat: String? = nil,
        onInfo: VoidAction = nil,
        onSelect: VoidAction = nil
    ) {
        self.value = value
        self.fiat = fiat
        self.onInfo = onInfo
        self.onSelect = onSelect
    }

    public var title: String {
        Localized.Transfer.networkFee
    }
}
