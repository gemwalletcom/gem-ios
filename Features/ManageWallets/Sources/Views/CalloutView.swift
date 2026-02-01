// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style

struct CalloutView: View {

    let title: String?
    let titleStyle: TextStyle
    let subtitle: String?
    let subtitleStyle: TextStyle
    let backgroundColor: Color

    var body: some View {
        VStack(alignment: .center, spacing: .medium) {
            if let title = title {
                Text(title)
                    .font(titleStyle.font)
                    .foregroundColor(titleStyle.color)
                    .multilineTextAlignment(.center)
            }
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(subtitleStyle.font)
                    .foregroundColor(subtitleStyle.color)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(.small)
    }
}

extension CalloutView {
    static func error(
        title: String?,
        subtitle: String?
    ) -> some View {
        return CalloutView(
            title: title,
            titleStyle: TextStyle(font: .system(.body, weight: .medium), color: Colors.red),
            subtitle: subtitle,
            subtitleStyle: TextStyle(font: .callout, color: Colors.red),
            backgroundColor: Colors.redLight
        )
    }
}
