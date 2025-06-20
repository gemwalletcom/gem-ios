// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct ListItemImageView: View {
    public let title: String
    public let subtitle: String
    public let assetImage: AssetImage?
    public let imageSize: CGFloat
    public let infoAction: (() -> Void)?
    
    public init(
        title: String,
        subtitle: String,
        assetImage: AssetImage? = nil,
        imageSize: CGFloat = .list.image,
        infoAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.assetImage = assetImage
        self.imageSize = imageSize
        self.infoAction = infoAction
    }
    
    public var body: some View {
        HStack {
            ListItemView(title: title, subtitle: subtitle, infoAction: infoAction)
            if let assetImage {
                AssetImageView(assetImage: assetImage, size: imageSize)
            }
        }
    }
}

public struct ListItemImageValue {
    public let title: String
    public let subtitle: String
    public let assetImage: AssetImage?
    
    public init(title: String, subtitle: String, assetImage: AssetImage?) {
        self.title = title
        self.subtitle = subtitle
        self.assetImage = assetImage
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
