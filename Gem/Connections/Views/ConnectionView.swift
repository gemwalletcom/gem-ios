// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct ConnectionView: View {
    
    let model: WalletConnectionViewModel
    
    var body: some View {
        HStack {
            AsyncImageView(url: model.imageUrl)
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                Text(model.host)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .contextMenu {
            if let url = model.url {
                ContextMenuViewURL(title: model.host, url: url, image: SystemImage.network)
            }
        }
    }
}
//#Preview {
//    ConnectionView()
//}
