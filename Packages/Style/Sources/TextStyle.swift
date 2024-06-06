// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct TextStyle {
    public let font: Font
    public let color: Color
    public let background: Color
    
    public init(
        font: Font,
        color: Color,
        background: Color = .primary
    ) {
        self.font = font
        self.color = color
        self.background = background
    }
}
