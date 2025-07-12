// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import PrimitivesComponents

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
                Text(model.displayName)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
        }
        .contextMenu {
            if let title = model.host, let url = model.url {
                ContextMenuItem(
                    title: title,
                    systemImage: SystemImage.globe
                ) {
                    isPresentingUrl = url
                }
            }
        }
        .safariSheet(url: $isPresentingUrl)
    }
}
