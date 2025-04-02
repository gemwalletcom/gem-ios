// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style

public struct BannerView: View {
    private let banners: [Banner]

    private let action: ((Banner) -> Void)
    private let closeAction: ((Banner) -> Void)

    public init(
        banners: [Banner],
        action: @escaping (Banner) -> Void,
        closeAction: @escaping (Banner) -> Void
    ) {
        self.banners = banners
        self.action = action
        self.closeAction = closeAction
    }

    public var body: some View {
        if let banner = banners.map({ BannerViewModel(banner: $0) }).first {
            Button(
                action: { action(banner.banner) },
                label: {
                    HStack(spacing: 0) {
                        ListItemView(
                            title: banner.title,
                            titleExtra: banner.description,
                            imageStyle: banner.imageStyle
                        )

                        if banner.canClose {
                            Spacer()

                            ListButton(
                                image: Images.System.xmarkCircle,
                                action: {
                                    closeAction(banner.banner)
                                }
                            )
                            .padding(.vertical, .small)
                            .foregroundColor(Colors.gray)
                        }
                    }
                })
        }
    }
}

