// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components

public struct InfoView: View {
    private let image: Image?

    private let title: TextValue
    private let description: TextValue

    init(model: any InfoModel) {
        self.init(title: model.title,
                  description: model.description,
                  image: model.image)
    }

    init(title: String,
         titleStyle: TextStyle = .headline,
         description: String,
         descriptionStyle: TextStyle = .subheadline,
         image: Image?
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
        image: Image? = nil
    ) {
        self.title = titleValue
        self.description = descriptionValue
        self.image = image
    }

    public var body: some View {
        VStack(spacing: Spacing.large) {
            image?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Sizing.image.large, height: Sizing.image.large)

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
    InfoView(title: "Network Fee",
             description: "The Tron network charges a transaction fee which varies based on blockhain usage",
             image: Image(systemName: SystemImage.bellFill)
    )
}
