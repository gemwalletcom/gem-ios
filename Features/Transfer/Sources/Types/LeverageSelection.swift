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
        options: [LeverageOption],
        selected: LeverageOption,
        textStyle: TextStyle = .callout
    ) {
        self.options = options
        self.selected = selected
        self.textStyle = textStyle
    }
}
