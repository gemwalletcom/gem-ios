// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components

public struct GridPosterViewItem: Identifiable, Sendable {
    public let id: String
    public let destination: any Hashable & Sendable
    public let assetImage: AssetImage
    public let title: String
    public let count: Int?

    public init(
        id: String,
        destination: any Hashable & Sendable,
        assetImage: AssetImage,
        title: String,
        count: Int? = nil
    ) {
        self.id = id
        self.destination = destination
        self.assetImage = assetImage
        self.title = title
        self.count = count
    }
}
