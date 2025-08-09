// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct AmountView: View {
    
    public let title: String
    public let subtitle: String?
    public let titleStyle: TextStyle
    public let subtitleStyle: TextStyle
    
    public init(
        title: String,
        subtitle: String? = nil,
        titleStyle: TextStyle? = nil,
        subtitleStyle: TextStyle? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.titleStyle = titleStyle ?? TextStyle(
            font: .system(size: 52),
            color: Colors.black,
            fontWeight: .semibold
        )
        self.subtitleStyle = subtitleStyle ?? TextStyle(
            font: .system(size: 16),
            color: Colors.gray,
            fontWeight: .medium
        )
    }
    
    // Convenience init for backward compatibility
    public init(title: String, subtitle: String?, titleColor: Color) {
        self.title = title
        self.subtitle = subtitle
        self.titleStyle = TextStyle(
            font: .system(size: 52),
            color: titleColor,
            fontWeight: .semibold
        )
        self.subtitleStyle = TextStyle(
            font: .system(size: 16),
            color: Colors.gray,
            fontWeight: .medium
        )
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: Spacing.extraSmall) {
            Text(title)
                .textStyle(titleStyle)
                .scaledToFit()
                .minimumScaleFactor(0.4)
                .truncationMode(.middle)
                .lineLimit(1)

            if let subtitle = subtitle {
                Text(subtitle)
                    .textStyle(subtitleStyle)
                    .lineLimit(1)
            }
        }
    }
}
