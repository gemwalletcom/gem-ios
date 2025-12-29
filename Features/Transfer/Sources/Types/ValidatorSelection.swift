// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Staking

@Observable
public final class ValidatorSelection {
    public let options: [DelegationValidator]
    public var selected: DelegationValidator?
    public let isPickerEnabled: Bool
    public let type: StakeValidatorsType

    public init(
        options: [DelegationValidator],
        selected: DelegationValidator? = nil,
        isPickerEnabled: Bool = true,
        type: StakeValidatorsType = .stake
    ) {
        self.options = options
        self.selected = selected ?? options.first
        self.isPickerEnabled = isPickerEnabled
        self.type = type
    }
}
