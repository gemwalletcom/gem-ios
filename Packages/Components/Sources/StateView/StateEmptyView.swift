// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct StateEmptyView: View {
    let title: String
    let messageTextStyle: TextStyle

    let description: String?
    let descriptionTextStyle: TextStyle

    let image: Image?

    public init(
        title: String,
        messageTextStyle: TextStyle = TextStyle(font: .headline, color: .primary),
        description: String? = nil,
        descriptionTextStyle: TextStyle = TextStyle(font: .footnote, color: .secondary),
        image: Image? = nil
    ) {
        self.title = title
        self.messageTextStyle = messageTextStyle
        self.description = description
        self.descriptionTextStyle = descriptionTextStyle
        self.image = image
    }


     public var body: some View {
         VStack(spacing: Spacing.medium) {
             image?
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: Sizing.image.chain, height: Sizing.image.chain, alignment: .center)

             VStack(spacing: description == nil ? 0 : Spacing.tiny) {
                 Text(title)
                     .font(messageTextStyle.font)
                     .multilineTextAlignment(.center)
                     .foregroundStyle(messageTextStyle.color)

                 if let description = description {
                     Text(description)
                         .font(descriptionTextStyle.font)
                         .multilineTextAlignment(.center)
                         .foregroundStyle(descriptionTextStyle.color)
                 }
             }
         }
         .tint(Colors.black)
     }
}

// MARK: - Previews

#Preview {
    VStack {
        // Default State
        StateEmptyView(
            title: "No Results Found",
            description: "Try adjusting your search or filter to find what you're looking for.",
            image: Image(systemName: SystemImage.searchNoResults)
        )
        Divider()

        // Without Description
        StateEmptyView(
            title: "No Results Found",
            image: Image(systemName: SystemImage.searchNoResults)
        )
        Divider()

        // Custom Colors and Styles
        StateEmptyView(
            title: "No Results Found",
            messageTextStyle: TextStyle(font: .title, color: .red),
            description: "Try adjusting your search or filter to find what you're looking for.",
            descriptionTextStyle: TextStyle(font: .body, color: .gray),
            image: Image(systemName: SystemImage.searchNoResults)
        )
        Divider()

        // No Image
        StateEmptyView(
            title: "No Results Found",
            description: "Try adjusting your search or filter to find what you're looking for."
        )
        Divider()

        // Only Message
        StateEmptyView(
            title: "No Results Found"
        )
        Divider()
    }
    .padding()
}
