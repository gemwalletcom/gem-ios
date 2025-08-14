// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct SectionHeaderActionView: View {
    private let title: String
    private let icon: Image?
    
    public init(title: String, icon: Image? = nil) {
        self.title = title
        self.icon = icon
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: Spacing.small) {
            if let icon = icon {
                icon
                    .frame(width: .medium, height: .medium)
            }
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(Colors.blue)
    }
}
