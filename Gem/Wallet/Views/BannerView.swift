// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style

struct BannerView: View {

    let banners: [Primitives.Banner]

    var action: ((Banner) -> Void)
    var closeAction: ((Banner) -> Void)

    var body: some View {
        ForEach(banners.map { BannerViewModel(banner: $0) }) { banner in
            Button(action: {
                action(banner.banner)
            }, label: {
                HStack(spacing: 0) {
                    ListItemView(
                        title: banner.title,
                        titleExtra: banner.description,
                        image: banner.image,
                        imageSize: banner.imageSize,
                        cornerRadius: banner.cornerRadius
                    )

                    Spacer()

                    if banner.canClose {
                        ListButton(
                            image: Image(systemName: SystemImage.xmarkCircle),
                            action: {
                                closeAction(banner.banner)
                            }
                        )
                        .padding(.vertical, Spacing.small)
                        .foregroundColor(Colors.gray)
                    }
                }
            })
        }
    }
}

