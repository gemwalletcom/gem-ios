// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct ContextMenuItem: View {
    private let title: String
    private let systemImage: String?
    private let role: ButtonRole?
    private let action: () -> Void
    private let defaultColor: Color

    public init(
        title: String,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        defaultColor: Color = Colors.black,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.defaultColor = defaultColor
        self.action = action
    }

    public var body: some View {
        Button(role: role, action: action) {
            if let systemImage {
                Label(title, systemImage: systemImage)
            } else {
                Text(title)
            }
        }
        .tint(role == .destructive ? Colors.red : Colors.black)
    }
}
