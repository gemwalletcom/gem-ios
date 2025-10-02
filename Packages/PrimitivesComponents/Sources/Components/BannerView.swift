// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style

public struct BannerView: View {
    private let model: BannerViewModel
    private let action: ((BannerAction) -> Void)

    public init(
        banner: Banner,
        action: @escaping (BannerAction) -> Void
    ) {
        self.model = BannerViewModel(banner: banner)
        self.action = action
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            switch model.viewType {
            case .list: listView
            case .banner: bannerView
            }
            
            if model.canClose {
                closeButton
                    .padding([.top, .trailing], .medium)
            }
        }
    }
}

// MARK: - Private Views

private extension BannerView {
    private var listView: some View {
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
                    }
                }
            }
        )
        .buttonStyle(.listStyleColor(glassEffect: .disabled))
    }

    private var bannerView: some View {
        VStack(spacing: .medium) {
            if let image = model.image {
                AssetImageView(assetImage: image, size: model.imageSize)
            }
            
            VStack(spacing: .small) {
                if let title = model.title {
                    Text(title)
                        .textStyle(TextStyle(font: .body, color: .primary, fontWeight: .semibold))
                }
                
                if let subtitle = model.description {
                    Text(subtitle)
                        .textStyle(.bodySecondary)
                }
            }
            .multilineTextAlignment(.center)

            HStack(spacing: .medium) {
                ForEach(model.buttons) { button in
                    Button {
                        action(button.action)
                    } label: {
                        Text(button.title)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(button.style)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    private var closeButton: some View {
        Button {
            action(model.closeAction)
        } label: {
            Images.System.xmark
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(Colors.gray)
                .padding(.tiny)
                .liquidGlass { _ in
                    ListButton(
                        image: Images.System.xmarkCircle,
                        action: { action(model.closeAction) }
                    )
                    .foregroundColor(Colors.gray)
                }
        }
        .buttonStyle(.borderless)
    }
}

