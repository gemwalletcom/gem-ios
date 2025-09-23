// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style

public struct BannerView: View {
    private let banners: [BannerViewModel]
    private let action: ((BannerAction) -> Void)
    
    @State private var currentIndex: Int? = 0

    public init(
        banners: [Banner],
        action: @escaping (BannerAction) -> Void
    ) {
        self.banners = banners.map(BannerViewModel.init)
        self.action = action
    }

    public var body: some View {
        if banners.isNotEmpty {
            VStack(spacing: .small) {
                carouselTabView
            }
        }
    }
}

// MARK: - Private Views

private extension BannerView {
    var carouselTabView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(banners.indices, id: \.self) { index in
                    bannerContent(for: banners[index])
                        .containerRelativeFrame(.horizontal)
                        .if(banners.count > 1) { view in
                            view.padding(.bottom, .small)
                        }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $currentIndex)
        .scrollDisabled(banners.count == 1)
        .overlay(alignment: .bottom) {
            if banners.count > 1 {
                carouselIndicators
                    .padding(.bottom, .small)
            }
        }
    }
    
    @ViewBuilder
    var carouselIndicators: some View {
        HStack(spacing: .tiny) {
            ForEach(0..<banners.count, id: \.self) { index in
                Circle()
                    .fill(index == (currentIndex ?? 0) ? Colors.blue : Colors.gray.opacity(0.3))
                    .frame(size: .space6)
            }
        }
    }
    
    @ViewBuilder
    func bannerContent(for model: BannerViewModel) -> some View {
        switch model.viewType {
        case .list: listView(for: model)
        case .banner: bannerView(for: model)
        }
    }
    
    @ViewBuilder
    private func listView(for model: BannerViewModel) -> some View {
        Button(
            action: { action(model.action) },
            label: {
                HStack(spacing: 0) {
                    ListItemView(
                        title: model.title,
                        titleExtra: model.description,
                        imageStyle: model.imageStyle
                    )

                    if model.canClose {
                        Spacer()

                        ListButton(
                            image: Images.System.xmarkCircle,
                            action: { action(model.closeAction) }
                        )
                        .padding(.vertical, .small)
                        .foregroundColor(Colors.gray)
                    }
                }
                .frame(maxHeight: .infinity)
            }
        )
        .buttonStyle(.listStyleColor())
    }
    
    @ViewBuilder
    private func bannerView(for model: BannerViewModel) -> some View {
        VStack(spacing: .medium) {
            if let image = model.image {
                AssetImageView(assetImage: image, size: model.imageSize)
            }
            
            if let title = model.title {
                Text(title)
                    .textStyle(TextStyle(font: .body, color: .primary, fontWeight: .semibold))
            }
            
            if let subtitle = model.description {
                Text(subtitle)
                    .textStyle(.calloutSecondary)
            }

            HStack(spacing: .medium) {
                ForEach(model.buttons) { button in
                    Button {
                        action(button.action)
                    } label: {
                        Text(button.title)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.blue(
                        paddingVertical: .small,
                        isGlassEffectEnabled: true
                    ))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

