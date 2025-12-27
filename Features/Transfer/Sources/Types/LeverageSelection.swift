// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import PrimitivesComponents
import Style

@Observable
public final class LeverageSelection {
    public let options: [LeverageOption]
    public var selected: LeverageOption
    public let textStyle: TextStyle

    public init(
        maxLeverage: UInt8,
        initial: LeverageOption,
        textStyle: TextStyle = .callout
    ) {
        self.options = LeverageOption.allOptions.filter { $0.value <= maxLeverage }
        self.selected = initial
        self.textStyle = textStyle
    }
}
