// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct AssetImage: Sendable, Equatable {
    public let type: String?
    public let imageURL: URL?
    public let placeholder: Image?
    public let chainPlaceholder: Image?

    public init(
        type: String? = .none,
        imageURL: URL? = .none,
        placeholder: Image? = .none,
        chainPlaceholder: Image? = .none
    ) {
        self.type = type
        self.imageURL = imageURL
        self.placeholder = placeholder
        self.chainPlaceholder = chainPlaceholder
    }

    public static func resourceImage(image: String) -> AssetImage {
        AssetImage(
            type: .none,
            imageURL: .none,
            placeholder: Images.name(image),
            chainPlaceholder: .none
        )
    }
    
    public static func image(_ image: Image) -> AssetImage {
        AssetImage(
            type: .none,
            imageURL: .none,
            placeholder: image,
            chainPlaceholder: .none
        )
    }
}
