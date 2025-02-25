// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Localization

public struct PercentageAccessoryView: View {
    public let onSelectPercentage: (Double) -> Void
    public let onDone: () -> Void
    
    public init(
        onSelectPercentage: @escaping (Double) -> Void,
        onDone: @escaping () -> Void
    ) {
        self.onSelectPercentage = onSelectPercentage
        self.onDone = onDone
    }
    
    public var body: some View {
        HStack {
            Group {
                Button(action: { onSelectPercentage(0.25) }) {
                    Text("25%")
                }
                Button(action: { onSelectPercentage(0.5) }) {
                    Text("50%")
                }
                Button(action: { onSelectPercentage(1.0) }) {
                    Text(Localized.Transfer.max)
                }
            }
            .buttonStyle(.lightGray(paddingVertical: Spacing.tiny))
            .frame(maxWidth: .infinity)

            Button(action: { onDone() }) {
                Text(Localized.Common.done)
            }
            .buttonStyle(.clear)
        }
    }
}
