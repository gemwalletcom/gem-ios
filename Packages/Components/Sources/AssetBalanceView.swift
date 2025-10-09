// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct AssetBalanceView<SecondaryView: View>: View {
    let image: AssetImage
    let title: String
    let balance: String?
    let secondary: () -> SecondaryView

    public init(
        image: AssetImage,
        title: String,
        balance: String?,
        @ViewBuilder secondary: @escaping () -> SecondaryView
    ) {
        self.image = image
        self.title = title
        self.balance = balance
        self.secondary = secondary
    }

    public var body: some View {
        ListItemFlexibleView(
            left: {
                AssetImageView(assetImage: image)
            }, primary: {
                VStack(alignment: .leading, spacing: .tiny) {
                    Text(title)
                        .textStyle(.headline.weight(.semibold))
                    if let balance {                    
                        Text(balance)
                            .textStyle(TextStyle(font: .callout, color: Colors.gray, fontWeight: .medium))
                    }
                }
                .lineLimit(1)
                .truncationMode(.tail)
            },
            secondary: secondary
        )
    }
}
