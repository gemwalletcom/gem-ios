// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct InfoView: View {
    private let image: Image?

    private let title: TextValue
    private let description: TextValue
    private let descriptionExtra: TextValue?

    public init(title: String,
                titleStyle: TextStyle = .headline,
                description: String,
                descriptionStyle: TextStyle = .subheadline,
                descriptionExtra: String? = nil,
                descriptionExtraStyle: TextStyle = .subheadline,
                image: Image?
    ) {
        let titleValue = TextValue(text: title, style: titleStyle)
        let descriptionValue = TextValue(text: description, style: descriptionStyle)
        let descriptionExtraValue = descriptionExtra.map { TextValue(text: $0, style: descriptionExtraStyle) }

        self.init(
            titleValue: titleValue,
            descriptionValue: descriptionValue,
            descriptionExtra: descriptionExtraValue,
            image: image
        )
    }

    public init(
        titleValue: TextValue,
        descriptionValue: TextValue,
        descriptionExtra: TextValue?,
        image: Image? = nil
    ) {
        self.title = titleValue
        self.description = descriptionValue
        self.descriptionExtra = descriptionExtra
        self.image = image
    }

    public var body: some View {
        VStack(spacing: Spacing.large) {
            image?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 75, height: 75)

            VStack(spacing: Spacing.medium) {
                Text(title.text)
                    .textStyle(title.style)
                    .multilineTextAlignment(.center)

                Text(description.text)
                    .textStyle(description.style)
                    .multilineTextAlignment(.center)

                if let descriptionExtra {
                    Text(descriptionExtra.text)
                        .textStyle(descriptionExtra.style)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.horizontal, Spacing.medium)
    }
}

// MARK: - Previews

#Preview {
    InfoView(title: "Network Fee",
             description: "The Tron network charges a transaction fee which varies based on blockhain usage",
             descriptionExtra: "0% fee",
             image: Image(systemName: SystemImage.bellFill)
    )
}
