// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct ListSection<T: Sendable>: Identifiable, Sendable {
    public let id: String
    public let title: String?
    public let image: Image?
    public let values: [T]
    
    public init(
        id: String,
        title: String?,
        image: Image?,
        values: [T]
    ) {
        self.id = id
        self.title = title
        self.image = image
        self.values = values
    }
}
