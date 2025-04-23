// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct ListItemFlexibleView<LeftView: View, PrimaryView: View, SecondaryView: View>: View {
    let left: LeftView
    let primary: PrimaryView
    let secondary: SecondaryView

    public init(
        @ViewBuilder left: () -> LeftView,
        @ViewBuilder primary: () -> PrimaryView,
        @ViewBuilder secondary: () -> SecondaryView
    ) {
        self.left = left()
        self.primary = primary()
        self.secondary = secondary()
    }

    public var body: some View {
        HStack(spacing: .space12) {
            left
            HStack {
                primary
                Spacer(minLength: .extraSmall)
                secondary
            }
        }
    }
}

#Preview {
    return ListItemFlexibleView(
        left:  { Circle().foregroundStyle(.red).frame(width: 30, height: 30) },
        primary: { Text("Primary") },
        secondary: { Text("Secondary") }
    )
}
