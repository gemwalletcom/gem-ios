// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct StateEmptyView<Content: View>: View {
    var title: TextValue
    let description: TextValue?
    let image: Image?
    let buttonsView: Content

    public init(
        title: String,
        titleTextStyle: TextStyle = .headline,
        description: String? = nil,
        descriptionTextStyle: TextStyle = .subHeadline,
        image: Image? = nil,
        @ViewBuilder buttons: (() -> Content) = { EmptyView() }
    ) {
        // set regular font if we have only title
        let titleStyle = (image == nil && description == nil) ? TextStyle(font: .body, color: titleTextStyle.color) : titleTextStyle
        let titleValue = TextValue(text: title, style: titleStyle)
        let descriptionValue = description.map { TextValue(text: $0, style: descriptionTextStyle) }

        self.init(
            titleValue: titleValue,
            descriptionValue: descriptionValue,
            image: image,
            buttons: buttons
        )
    }

    init(
        titleValue: TextValue,
        descriptionValue: TextValue? = nil,
        image: Image? = nil,
        @ViewBuilder buttons: () -> Content = { EmptyView() }
    ) {
        self.title = titleValue
        self.description = descriptionValue
        self.image = image
        self.buttonsView = buttons()
    }

     public var body: some View {
         VStack(spacing: .medium) {
             if let image {
                 ZStack {
                     Circle()
                         .foregroundStyle(Colors.Empty.imageBackground)
                     image
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(
                            width: Sizing.image.medium,
                            height: Sizing.image.medium
                         )
                         .foregroundStyle(Colors.Empty.image)
                 }
                 .frame(
                    width: .image.large,
                    height: .image.large
                 )
             }

             VStack(spacing: description == nil ? 0 : .tiny) {
                 HStack(spacing: 0.0) {
                     Text(title.text)
                         .textStyle(title.style)
                         .multilineTextAlignment(.center)
                     if description == nil && image == nil {
                         Spacer()
                     }
                 }
                 .frame(maxWidth: .infinity)

                 if let description {
                     Text(description.text)
                         .textStyle(description.style)
                         .multilineTextAlignment(.center)
                 }
             }
             buttonsView
         }
         .tint(Colors.black)
     }
}

// MARK: - Previews

#Preview {
    List {
        Section(header: Text("Full View with Title, Description, and Image")) {
            StateEmptyView(
                title: "No Results Found",
                description: "Try adjusting your search or filter to find what you're looking for.",
                image: Images.EmptyContent.nft
            )
        }

        Section(header: Text("View with Title and Image")) {
            StateEmptyView(
                title: "No Results Found",
                image: Images.EmptyContent.search
            )
        }

        Section(header: Text("View with Custom Title and Description Styles")) {
            StateEmptyView(
                title: "No Results Found",
                titleTextStyle: .title,
                description: "Try adjusting your search or filter to find what you're looking for.",
                descriptionTextStyle: .body,
                image: Images.EmptyContent.search
            )
        }

        Section(header: Text("View with Title and Description")) {
            StateEmptyView(
                title: "No Results Found",
                description: "Try adjusting your search or filter to find what you're looking for."
            )
        }

        Section(header: Text("View with Only Title")) {
            StateEmptyView(
                title: "No Results Found"
            )
        }
    }
    .padding()
}
