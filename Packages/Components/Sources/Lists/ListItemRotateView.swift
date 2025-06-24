// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct ListItemRotateView: View {
    public let title: String
    public let subtitle: String
    public let action: (() -> Void)

    public init(title: String, subtitle: String, action: @escaping (() -> Void)) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                ListItemImageView(
                    title: title,
                    subtitle: subtitle
                )

                Images.Actions.swap
                    .resizable()
                    .renderingMode(.template)
                    .frame(size: .list.accessory)
                    .foregroundStyle(Colors.gray)
            }
        }
    }
}
