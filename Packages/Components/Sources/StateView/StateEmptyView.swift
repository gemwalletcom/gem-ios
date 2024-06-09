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
        titleTextStyle: TextStyle = .headline,
        description: String? = nil,
        descriptionTextStyle: TextStyle = .footnote,
        image: Image? = nil
    ) {
        // set regular font if we have only title
        let titleStyle = (image == nil && description == nil) ? TextStyle(font: .body, color: titleTextStyle.color) : titleTextStyle
        let titleValue = TextValue(text: title, style: titleStyle)
        let descriptionValue = description.map { TextValue(text: $0, style: descriptionTextStyle) }

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

                 if let description {
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
