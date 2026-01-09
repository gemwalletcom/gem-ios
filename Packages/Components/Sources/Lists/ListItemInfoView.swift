// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct ListItemInfoView: View {
    let title: String
    let description: String?
    let icon: Image
    let iconColor: Color

    public init(
        title: String,
        description: String? = nil,
        icon: Image = Images.System.info,
        iconColor: Color = Colors.orange
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.iconColor = iconColor
    }

    public var body: some View {
        HStack(alignment: .top, spacing: Spacing.medium) {
            icon
                .foregroundStyle(iconColor)

            VStack(alignment: .leading, spacing: Spacing.small) {
                Text(title)
                    .textStyle(.headline)
                if let description {
                    Text(description)
                        .textStyle(.calloutSecondary)
                }
            }
        }
    }
}

#Preview {
    List {
        Section {
            ListItemInfoView(
                title: "Pending Verification",
                description: "Activate in 23 hours to receive your rewards."
            )
        }

        Section {
            ListItemInfoView(
                title: "Info Only",
                description: nil
            )
        }

        Section {
            ListItemInfoView(
                title: "Custom Icon",
                description: "With warning icon",
                icon: Images.System.exclamationmarkTriangle,
                iconColor: Colors.red
            )
        }
    }
}
