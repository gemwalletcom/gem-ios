// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Style

public struct ListItemImageStyle: Sendable {
    public let assetImage: AssetImage
    public let imageSize: CGFloat
    private let cornerRadiusType: CornerRadiusType
    
    public var cornerRadius: CGFloat {
        switch cornerRadiusType {
        case .none: .zero
        case .rounded: imageSize / 2
        case .custom(let radius): radius
        }
    }

    public init?(
        assetImage: AssetImage?,
        imageSize: CGFloat,
        cornerRadiusType: CornerRadiusType
    ) {
        guard let assetImage else { return nil }
        self.assetImage = assetImage
        self.imageSize = imageSize
        self.cornerRadiusType = cornerRadiusType
    }
    
    public enum CornerRadiusType: Sendable {
        case none
        case rounded
        case custom(CGFloat)
    }
}

public extension ListItemImageStyle {
    static func asset(assetImage: AssetImage?) -> Self? {
        ListItemImageStyle(
            assetImage: assetImage,
            imageSize: .image.asset,
            cornerRadiusType: .rounded
        )
    }
    
    static func list(assetImage: AssetImage?) -> Self? {
        ListItemImageStyle(
            assetImage: assetImage,
            imageSize: .list.image,
            cornerRadiusType: .none
        )
    }
    
    static func settings(assetImage: AssetImage?) -> Self? {
        ListItemImageStyle(
            assetImage: assetImage,
            imageSize: .list.settings,
            cornerRadiusType: .none
        )
    }
}
