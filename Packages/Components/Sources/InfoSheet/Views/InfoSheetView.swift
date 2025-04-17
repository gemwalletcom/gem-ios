// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct InfoSheetView: View {
    private let image: InfoSheetImage?

    private let title: TextValue
    private let description: TextValue

    init(model: any InfoSheetModelViewable) {
        self.init(
            title: model.title,
            description: model.description,
            image: model.image
        )
    }

    init(
        title: String,
        titleStyle: TextStyle = .boldTitle,
        description: String,
        descriptionStyle: TextStyle = .bodySecondary,
        image: InfoSheetImage?
    ) {
        let titleValue = TextValue(text: title, style: titleStyle)
        let descriptionValue = TextValue(text: description, style: descriptionStyle)

        self.init(
            titleValue: titleValue,
            descriptionValue: descriptionValue,
            image: image
        )
    }

    init(
        titleValue: TextValue,
        descriptionValue: TextValue,
        image: InfoSheetImage? = nil
    ) {
        self.title = titleValue
        self.description = descriptionValue
        self.image = image
    }

    var body: some View {
        ViewThatFits(in: .vertical) {
            regularLayout
            compactLayout
        }
    }

    @ViewBuilder
    var regularLayout: some View {
        content(
            vSpacing: .medium,
            titleStyle: title.style,
            descriptionStyle: description.style,
            imageSize: .image.semiExtraLarge,
            overlayImageSize: .image.medium
        )
        .padding(.horizontal, .small)
    }

    @ViewBuilder
    var compactLayout: some View {
        content(
            vSpacing: .small,
            titleStyle: title.style.stepDown,
            descriptionStyle: description.style.stepDown,
            imageSize: .image.large,
            overlayImageSize: .image.semiMedium
        )
        .padding(.horizontal, .extraSmall)
    }

    private func content(
        vSpacing: CGFloat,
        titleStyle: TextStyle,
        descriptionStyle: TextStyle,
        imageSize: CGFloat,
        overlayImageSize: CGFloat
    ) -> some View {
        VStack(spacing: vSpacing) {
            Group {
                switch image {
                case .image(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .assetImage(let asset):
                    AssetImageView(
                        assetImage: asset,
                        size: imageSize,
                        overlayImageSize: overlayImageSize
                    )
                case nil: EmptyView()
                }
            }
            .frame(size: imageSize)

            VStack(spacing: .small) {
                Text(title.text)
                    .textStyle(titleStyle)
                Text(description.text)
                    .textStyle(descriptionStyle)
            }
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

// MARK: - Previews

#Preview {
    InfoSheetView(
        title: "Network Fee",
        description: "The Tron network charges a transaction fee which varies based on blockhain usage",
        image: .image(Images.System.bellFill)
    )
}
