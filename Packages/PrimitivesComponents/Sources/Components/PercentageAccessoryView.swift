// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Localization

public struct PercentageAccessoryView: View {

    public let percents: [Int]
    public let onSelectPercent: (Int) -> Void
    public let onDone: () -> Void

    public init(
        percents: [Int],
        onSelectPercent: @escaping (Int) -> Void,
        onDone: @escaping () -> Void
    ) {
        self.percents = percents
        self.onSelectPercent = onSelectPercent
        self.onDone = onDone
    }
    
    public var body: some View {
        HStack {
            Group {
                ForEach(percents, id: \.self) { percent in
                    Button(action: { onSelectPercent(percent) }) {
                        Text("\(percent)%")
                    }
                }
            }
            .buttonStyle(.listStyleColor(paddingVertical: .small, cornerRadius: .small))
            .frame(maxWidth: .infinity)

            Button(action: onDone) {
                Text(Localized.Common.done)
            }
            .buttonStyle(.clear)
            .padding(.horizontal, .small)
        }
    }
}
