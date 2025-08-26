// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct ListItemImageView: View {
    public let title: String?
    public let subtitle: String?
    public let subtitleStyle: TextStyle
    public let assetImage: AssetImage?
    public let imageSize: CGFloat
    public let infoAction: (() -> Void)?
    
    public init(
        title: String?,
        subtitle: String?,
        subtitleStyle: TextStyle = .calloutSecondary,
        assetImage: AssetImage? = nil,
        imageSize: CGFloat = .list.image,
        infoAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.subtitleStyle = subtitleStyle
        self.assetImage = assetImage
        self.imageSize = imageSize
        self.infoAction = infoAction
    }
    
    public var body: some View {
        HStack {
            ListItemView(
                title: title,
                subtitle: subtitle,
                subtitleStyle: subtitleStyle,
                infoAction: infoAction
            )
            if let assetImage {
                AssetImageView(assetImage: assetImage, size: imageSize)
            }
        }
    }
}

#Preview {
    ListItemImageView(
        title: "Title",
        subtitle: "Subtitle",
        assetImage: .resourceImage(image: "logo")
    )
    ListItemImageView(
        title: "Title",
        subtitle: "Subtitle",
        assetImage: nil
    )
}
