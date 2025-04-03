// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import SwiftUI
import Components

public struct InsightLink {

    public let title: String
    public let subtitle: String?
    public var url: URL
    public let image: AssetImage
    
    public init(
        title: String,
        subtitle: String?,
        url: URL,
        image: AssetImage
    ) {
        self.title = title
        self.subtitle = subtitle
        self.url = url
        self.image = image
    }
}

extension InsightLink: Identifiable {
    public var id: String { title + url.absoluteString }
}
