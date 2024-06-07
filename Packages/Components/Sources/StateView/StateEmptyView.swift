// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct StateEmptyView: View {
    var title: TextValue
    let description: TextValue?

    let image: Image?

    public init(
        title: String,
        titleTextStyle: TextStyle = TextStyle(font: .headline, color: Colors.black),
        description: String? = nil,
        descriptionTextStyle: TextStyle = TextStyle(font: .footnote, color: Colors.secondaryText),
        image: Image? = nil
    ) {
        var titleValue = TextValue(text: title, style: titleTextStyle)
        var descriptionValue: TextValue?
        if let description = description {
            descriptionValue = TextValue(text: description, style: descriptionTextStyle)
        }

        if image == nil && description == nil {
            // set regular font if we have only title
            titleValue = TextValue(text: titleValue.text, style: TextStyle(font: .body, color: titleValue.style.color))
        }
        self.init(titleValue: titleValue, descriptionValue: descriptionValue, image: image)
    }

    public init(
        titleValue: TextValue,
        descriptionValue: TextValue? = nil,
        image: Image? = nil
    ) {
        self.title = titleValue
        self.description = descriptionValue
        self.image = image
    }

     public var body: some View {
         VStack(spacing: Spacing.medium) {
             image?
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: Sizing.image.chain, height: Sizing.image.chain, alignment: .center)
                 .foregroundStyle(Colors.gray)

             VStack(spacing: description == nil ? 0 : Spacing.tiny) {
                 Text(title.text)
                     .textStyle(title.style)
                     .multilineTextAlignment(.center)

                 if let description = description {
                     Text(description.text)
                         .textStyle(description.style)
                         .multilineTextAlignment(.center)
                 }
             }
         }
         .tint(Colors.black)
     }
}

// MARK: - Previews

#Preview {
    VStack {
        StateEmptyView(
            title: "No Results Found",
            description: "Try adjusting your search or filter to find what you're looking for.",
            image: Image(systemName: SystemImage.searchNoResults)
        )
        Divider()

        StateEmptyView(
            title: "No Results Found",
            image: Image(systemName: SystemImage.searchNoResults)
        )
        Divider()

        StateEmptyView(
            title: "No Results Found",
            titleTextStyle: .title,
            description: "Try adjusting your search or filter to find what you're looking for.",
            descriptionTextStyle: .body,
            image: Image(systemName: SystemImage.searchNoResults)
        )
        Divider()

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
