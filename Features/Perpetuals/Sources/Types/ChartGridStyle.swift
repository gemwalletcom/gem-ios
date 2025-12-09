// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Charts
import Style

struct ChartGridStyle {
    static let opacity: Double = 0.13
    static let lineWidth: CGFloat = 1
    static let dash: [CGFloat] = [4, 4]
    static let strokeStyle = StrokeStyle(lineWidth: lineWidth, dash: dash)
    static let color = Colors.gray.opacity(opacity)
}
