// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct PropertyView: View {
    public let title: String
    public let value: String
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.tiny) {
            Text(title.uppercased())
                .textStyle(.caption)
                .lineLimit(1)
            
            Text(value)
                .textStyle(.body)
                .lineLimit(1)
        }
        .padding(Spacing.small)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Colors.secondaryText, lineWidth: 1)
        )
    }
}
