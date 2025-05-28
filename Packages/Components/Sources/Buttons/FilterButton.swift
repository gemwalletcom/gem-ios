// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct FilterButton: View {
    private let isActive: Bool
    private let action: () -> Void

    public init(isActive: Bool, action: @escaping () -> Void) {
        self.isActive = isActive
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            if isActive {
                Images.System.filterFill
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Colors.whiteSolid, Colors.blue)
            } else {
                Images.System.filter
                    .foregroundStyle(.primary)
            }
        }
        .accessibilityIdentifier(.filterButton)
        .contentTransition(.symbolEffect(.replace))
    }
}

#Preview {
    FilterButton(isActive: true, action: {})
}
