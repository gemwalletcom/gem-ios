// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct ContextMenuItem: View {
    private let title: String
    private let systemImage: String?
    private let role: ButtonRole?
    private let action: () -> Void

    public init(
        title: String,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.action = action
    }

    public var body: some View {
        Button(role: role) {
            action()
        } label: {
            if let systemImage {
                Label(title, systemImage: systemImage)
            } else {
                Text(title)
            }
        }
        .tint(Colors.gray)
    }
}
