// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Style

struct CurrencyViewModel: Sendable {
    let currency: Currency

    var flag: String? { Emoji.Flags.flagsByIdentifier[id] }
    var nativeCurrency: Locale.Currency? { Locale.Currency(id) }

    var title: String {
        let localizedName = Locale.current.localizedString(forCurrencyCode: id) ?? .empty

        if let flag = flag {
            return "\(flag) \(id) - \(localizedName)"
        } else {
            return "\(id) - \(localizedName)"
        }
    }
}

// MARK: - Identifiable

extension CurrencyViewModel: Identifiable {
    var id: String { currency.rawValue }
}
