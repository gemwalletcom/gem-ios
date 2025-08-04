// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension ValueFormatter {
    static let short = ValueFormatter(style: .short)
    static let medium = ValueFormatter(style: .medium)
    static let full = ValueFormatter(style: .full)
    static let auto = ValueFormatter(style: .auto)
    static let abbreviated = ValueFormatter(style: .abbreviated)
    static let full_US = ValueFormatter(locale: Locale.US, style: .full)
}
