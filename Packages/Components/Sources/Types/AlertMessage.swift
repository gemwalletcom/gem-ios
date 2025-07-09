// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct AlertMessage: Identifiable, Sendable {
    public var id: String { (title ?? "") + message }
    
    public let title: String?
    public let message: String
    
    public init(
        title: String? = nil,
        message: String
    ) {
        self.title = title
        self.message = message
    }
}