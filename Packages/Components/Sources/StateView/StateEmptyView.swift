// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct StateEmptyView: View {
    var titleValue: TextValueView
    let descriptionValue: TextValueView?

    let image: Image?

    public init(
        title: String,
        titleTextStyle: TextStyle = TextStyle(font: .headline, color: Colors.black),
        description: String? = nil,
        descriptionTextStyle: TextStyle = TextStyle(font: .footnote, color: Colors.secondaryText),
        image: Image? = nil
    ) {
        var titleValue = TextValueView(text: title, style: titleTextStyle)
        var descriptionValue: TextValueView?
        if let description = description {
            descriptionValue = TextValueView(text: description, style: descriptionTextStyle)
        }

        if image == nil && description == nil {
            // set regular font if we have only title
            titleValue = TextValueView(text: titleValue.text, style: TextStyle(font: .body, color: titleValue.style.color))
        }
        self.init(titleValue: titleValue, descriptionValue: descriptionValue, image: image)
    }

    public init(
        titleValue: TextValueView,
        descriptionValue: TextValueView? = nil,
        image: Image? = nil
    ) {
        self.titleValue = titleValue
        self.descriptionValue = descriptionValue
        self.image = image
    }

     public var body: some View {
         VStack(spacing: Spacing.medium) {
             image?
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: Sizing.image.chain, height: Sizing.image.chain, alignment: .center)
                 .foregroundStyle(Colors.gray)

             VStack(spacing: descriptionValue == nil ? 0 : Spacing.tiny) {
                 Text(titleValue.text)
                     .font(titleValue.style.font)
                     .multilineTextAlignment(.center)
                     .foregroundStyle(titleValue.style.color)

                 if let description = descriptionValue {
                     Text(description.text)
                         .font(description.style.font)
                         .multilineTextAlignment(.center)
                         .foregroundStyle(description.style.color)
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
            titleTextStyle: TextStyle(font: .title, color: .red),
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
