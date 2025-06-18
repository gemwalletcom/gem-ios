// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension ValueFormatter {
    static let short = ValueFormatter(style: .short)
    static let medium = ValueFormatter(style: .medium)
    static let full = ValueFormatter(style: .full)
    static let full_US = ValueFormatter(locale: Locale.US, style: .full)
}
