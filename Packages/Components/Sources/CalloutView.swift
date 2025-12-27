// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct CalloutViewStyle {
    public let title: TextValue?
    public let subtitle: TextValue?
    public let backgroundColor: Color
    
    public init(
        title: TextValue?,
        subtitle: TextValue?,
        backgroundColor: Color
    ) {
        self.title = title
        self.subtitle = subtitle
        self.backgroundColor = backgroundColor
    }
}

public struct CalloutView: View {

    public let style: CalloutViewStyle
    
    public init(style: CalloutViewStyle) {
        self.style = style
    }

    public var body: some View {
        VStack(alignment: .center, spacing: .medium) {
            if let title = style.title {
                Text(title.text)
                    .font(title.style.font)
                    .foregroundColor(title.style.color)
                    .multilineTextAlignment(.center)
            }
            if let subtitle = style.subtitle {
                Text(subtitle.text)
                    .font(subtitle.style.font)
                    .foregroundColor(subtitle.style.color)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.small)
        .background(style.backgroundColor)
        .cornerRadius(.small)
        .padding(.horizontal, .medium)
        .frame(maxWidth: .scene.content.maxWidth)
    }
}
