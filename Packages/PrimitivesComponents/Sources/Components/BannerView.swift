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
        let bannerViewModels = banners.map { BannerViewModel(banner: $0) }
        
        if bannerViewModels.isEmpty {
            EmptyView()
        } else if bannerViewModels.count == 1, let banner = bannerViewModels.first {
            bannerItem(for: banner)
        } else {
            TabView {
                ForEach(bannerViewModels) { banner in
                    bannerItem(for: banner)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: bannerHeight)
        }
    }
    
    private func bannerItem(for banner: BannerViewModel) -> some View {
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
                        .padding(.vertical, Spacing.small)
                        .foregroundColor(Colors.gray)
                    }
                }
            })
    }
    
    private var bannerHeight: CGFloat {
        60
    }
}

