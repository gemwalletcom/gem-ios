// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct StateEmptyView: View {
    let message: String
    let messageTextStyle: TextStyle

    let description: String?
    let descriptionTextStyle: TextStyle

    let image: Image?

    public init(
        message: String,
        messageTextStyle: TextStyle = TextStyle(font: .headline, color: .primary),
        description: String? = nil,
        descriptionTextStyle: TextStyle = TextStyle(font: .footnote, color: .secondary),
        image: Image? = nil
    ) {
        self.message = message
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
                 Text(message)
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
            message: "No Results Found",
            description: "Try adjusting your search or filter to find what you're looking for.",
            image: Image(systemName: SystemImage.searchNoResults)
        )
        Divider()

        // Without Description
        StateEmptyView(
            message: "No Results Found",
            image: Image(systemName: SystemImage.searchNoResults)
        )
        Divider()

        // Custom Colors and Styles
        StateEmptyView(
            message: "No Results Found",
            messageTextStyle: TextStyle(font: .title, color: .red),
            description: "Try adjusting your search or filter to find what you're looking for.",
            descriptionTextStyle: TextStyle(font: .body, color: .gray),
            image: Image(systemName: SystemImage.searchNoResults)
        )
        Divider()

        // No Image
        StateEmptyView(
            message: "No Results Found",
            description: "Try adjusting your search or filter to find what you're looking for."
        )
        Divider()

        // Only Message
        StateEmptyView(
            message: "No Results Found"
        )
        Divider()
    }
    .padding()
}
