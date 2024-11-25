// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct MarketValueViewModel {
    public let title: String
    public let subtitle: String?
    public let value: String?
    public let url: URL?
    
    public init(
        title: String,
        subtitle: String?,
        value: String?,
        url: URL?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.url = url
    }
}
