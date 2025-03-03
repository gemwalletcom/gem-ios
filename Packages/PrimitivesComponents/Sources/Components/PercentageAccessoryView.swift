// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Localization

public struct PercentageAccessoryView: View {
    public let onSelectBPS: (Int) -> Void
        public let onDone: () -> Void
        
        public init(
            onSelectBPS: @escaping (Int) -> Void,
            onDone: @escaping () -> Void
        ) {
            self.onSelectBPS = onSelectBPS
            self.onDone = onDone
        }
    
    public var body: some View {
        HStack {
            Group {
                Button(action: { onSelectBPS(2500) }) {
                    Text("25%")
                }
                Button(action: { onSelectBPS(5000) }) {
                    Text("50%")
                }
                Button(action: { onSelectBPS(10000) }) {
                    Text("100%")
                }
            }
            .buttonStyle(.lightGray(paddingVertical: .tiny))
            .frame(maxWidth: .infinity)

            Button(action: onDone) {
                Text(Localized.Common.done)
            }
            .buttonStyle(.clear)
            .padding(.horizontal, .small)
        }
    }
}
