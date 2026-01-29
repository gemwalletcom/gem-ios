// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

protocol LocalizedQRCodeError: LocalizedError {
    var titleImage: ErrorTitleImage? { get }
}
