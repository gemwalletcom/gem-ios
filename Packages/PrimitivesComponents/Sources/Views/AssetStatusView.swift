// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization

public struct AssetStatusView: View {
    private let model: AssetScoreTypeViewModel
    private let action: () -> Void

    public init(
        model: AssetScoreTypeViewModel,
        action: @escaping () -> Void
    ) {
        self.model = model
        self.action = action
    }

    public var body: some View {
        NavigationCustomLink(with:
            ListItemImageView(
                title: Localized.Transaction.status,
                subtitle: model.status,
                subtitleStyle: model.statusStyle,
                assetImage: model.assetImage,
                infoAction: action
            )
        ) {
            action()
        }
    }
}
