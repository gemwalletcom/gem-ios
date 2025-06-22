// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct ButtonStylePalette: Hashable, Sendable {
    public let foreground: Color
    public let foregroundPressed: Color
    public let background: Color
    public let backgroundPressed: Color
    public let backgroundDisabled: Color

    public init(
        foreground: Color,
        foregroundPressed: Color,
        background: Color,
        backgroundPressed: Color,
        backgroundDisabled: Color
    ) {
        self.foreground = foreground
        self.foregroundPressed = foregroundPressed
        self.background = background
        self.backgroundPressed = backgroundPressed
        self.backgroundDisabled = backgroundDisabled
    }

    public static let primary = ButtonStylePalette(
        foreground: Colors.whiteSolid,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.blue,
        backgroundPressed: Colors.blueDark,
        backgroundDisabled: Colors.blueDark.opacity(0.6)
    )
    
    public static let secondary = ButtonStylePalette(
        foreground: Colors.whiteSolid,
        foregroundPressed: Colors.whiteSolid,
        background: Colors.blueSecondary,
        backgroundPressed: Colors.blueSecondaryHover,
        backgroundDisabled: Colors.blueSecondary.opacity(0.6)
    )
}
