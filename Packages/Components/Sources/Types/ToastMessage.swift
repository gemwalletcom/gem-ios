// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct ToastMessage: Identifiable {
    public var id: String { title + image }
    
    public let title: String
    public let image: String
    
    public init(
        title: String,
        image: String
    ) {
        self.title = title
        self.image = image
    }
}

extension ToastMessage {
    static func empty() -> ToastMessage {
        ToastMessage(title: "", image: "")
    }
}
