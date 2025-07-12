// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import PrimitivesComponents
import Localization

public struct ConnectionView: View {
    @State private var isPresentingUrl: URL? = nil
    public let model: WalletConnectionViewModel

    public init(model: WalletConnectionViewModel) {
        self.model = model
    }

    public var body: some View {
        HStack {
            AsyncImageView(url: model.imageUrl)
            VStack(alignment: .leading) {
                Text(model.nameText)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                if let host = model.hostText {
                    Text(host)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .contextMenu {
            if let url = model.url {
                ContextMenuItem(
                    title: Localized.Settings.website,
                    systemImage: SystemImage.globe
                ) {
                    isPresentingUrl = url
                }
            }
        }
        .safariSheet(url: $isPresentingUrl)
    }
}
