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
        if let banner = banners.map({ BannerViewModel(banner: $0) }).first {
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

                    if banner.canClose {
                        Spacer()
                        
                        ListButton(
                            image: Images.System.xmarkCircle,
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

