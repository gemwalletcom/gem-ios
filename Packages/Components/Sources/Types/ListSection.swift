// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct ListSection<T: Sendable & Identifiable>: Identifiable, Sendable {
    public let id: String
    public let title: String?
    public let image: Image?
    public let values: [T]

    public init<ID: RawRepresentable>(
        type: ID,
        title: String? = nil,
        image: Image? = nil,
        values: [T]
    ) where ID.RawValue == String {
        self.init(
            id: type.rawValue,
            title: title,
            image: image,
            values: values
        )
    }

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
