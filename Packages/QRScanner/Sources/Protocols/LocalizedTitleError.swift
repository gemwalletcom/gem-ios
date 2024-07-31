// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol LocalizedQRCodeError: LocalizedError {
    var titleImage: ErrorTitleImage? { get }
}
