// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension ValueFormatter {
    public static let short = ValueFormatter(style: .short)
    public static let medium = ValueFormatter(style: .medium)
    public static let full = ValueFormatter(style: .full)
    
    public static let full_US = ValueFormatter(locale: Locale.US, style: .full)
}
