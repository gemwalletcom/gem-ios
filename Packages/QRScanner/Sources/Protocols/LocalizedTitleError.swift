// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol LocalizedQRError: LocalizedError {
    var titleImage: (title: String, systemImage: String)? { get }
}
