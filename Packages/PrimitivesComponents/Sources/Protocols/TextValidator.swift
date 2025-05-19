// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol TextValidator: Sendable, Identifiable {
    func validate(_ text: String) throws
}
