// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct InfoSheetView: View {
    private let image: InfoSheetImage?

    private let title: TextValue
    private let description: TextValue

    init(
        model: any InfoSheetModelViewable
    ) {
        self.init(
            title: model.title,
            description: model.description,
            image: model.image
        )
    }

    init(
        title: String,
        titleStyle: TextStyle = .title2,
        description: String,
        descriptionStyle: TextStyle = .body,
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
        VStack(spacing: Spacing.large) {
            ZStack {
                switch image {
                case .image(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Sizing.image.extraLarge, height: Sizing.image.extraLarge)
                case .assetImage(let assetImage):
                    AssetImageView(
                        assetImage: assetImage,
                        size: Sizing.image.extraLarge,
                        overlayImageSize: Sizing.image.extraLarge / 2.5
                    )
                case nil: EmptyView()
                }
            }
            
            VStack(spacing: Spacing.medium) {
                Text(title.text)
                    .textStyle(title.style)
                    .multilineTextAlignment(.center)

                Text(description.text)
                    .textStyle(description.style)
                    .multilineTextAlignment(.center)
            }
        }
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
