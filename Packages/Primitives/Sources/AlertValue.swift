// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct AlertValue: Error, Identifiable {
    public var id: String { [title,message].joined() }

    public let title: String
    public let message: String
    
    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}
