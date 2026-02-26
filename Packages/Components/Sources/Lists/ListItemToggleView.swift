// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct ListItemToggleView: View {
    @Binding private var isOn: Bool

    private let title: TextValue
    private let imageStyle: ListItemImageStyle?

    public init(
        isOn: Binding<Bool>,
        title: String,
        imageStyle: ListItemImageStyle? = nil,
        titleStyle: TextStyle = .body
    ) {
        _isOn = isOn
        self.title = TextValue(text: title, style: titleStyle)
        self.imageStyle = imageStyle
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            HStack(alignment: imageStyle?.alignment ?? .center, spacing: .space12) {
                if let imageStyle {
                    AssetImageView(
                        assetImage: imageStyle.assetImage,
                        size: imageStyle.imageSize,
                        style: .init(cornerRadius: imageStyle.cornerRadius)
                    )
                }
                Text(title.text)
                    .textStyle(title.style)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
        .toggleStyle(AppToggleStyle())
    }
}

// MARK: - Previews

#Preview {
    struct TogglePreviewHost: View {
        @State private var basicOn = true
        @State private var longOn = false
        @State private var imageOn = true
        @State private var combinedOn = false

        var body: some View {
            let defaultTitle = "Has Balance"
            let longTitle = "Very Long Title That Keeps Going And Might Truncate"
            let textStyle = TextStyle.body
            let imageStyle = ListItemImageStyle
                .list(assetImage: AssetImage.image(Images.System.faceid))

            List {
                Section("Basic States") {
                    ListItemToggleView(
                        isOn: $basicOn,
                        title: defaultTitle,
                        titleStyle: textStyle
                    )
                }
                Section("Long Text States") {
                    ListItemToggleView(
                        isOn: $longOn,
                        title: longTitle,
                        titleStyle: textStyle
                    )
                }
                Section("Image States") {
                    ListItemToggleView(
                        isOn: $imageOn,
                        title: defaultTitle,
                        imageStyle: imageStyle,
                        titleStyle: textStyle
                    )
                }
                Section("Combined States") {
                    ListItemToggleView(
                        isOn: $combinedOn,
                        title: longTitle,
                        imageStyle: imageStyle,
                        titleStyle: textStyle
                    )
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    return TogglePreviewHost()
}
