// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

extension Font {
    var textStyle: Font.TextStyle? {
        Font.TextStyle.allCases.first { Font.system($0) == self }
    }

    func step(offset: Int = 1) -> Font {
        guard let style = textStyle else { return self }
        let newRank = style.rank + offset
        let newStyle = Font.TextStyle.from(rank: newRank)
        return Font.system(newStyle)
    }

    var smaller: Font { step(offset: +1) }
    var larger: Font { step(offset: -1) }
}

extension Font.TextStyle {
    var rank: Int {
        switch self {
        case .largeTitle: 0
        case .title: 1
        case .title2: 2
        case .title3: 3
        case .headline: 4
        case .subheadline: 5
        case .body: 6
        case .callout: 7
        case .footnote: 8
        case .caption: 9
        case .caption2: 10
        @unknown default: 10
        }
    }

    static func from(rank: Int) -> Self {
        let minRank = 0
        let maxRank = 10
        return switch rank.clamped(to: minRank...maxRank) {
        case 0: .largeTitle
        case 1: .title
        case 2: .title2
        case 3: .title3
        case 4: .headline
        case 5: .subheadline
        case 6: .body
        case 7: .callout
        case 8: .footnote
        case 9: .caption
        default: .caption2
        }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
