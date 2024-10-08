// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

enum WalletImportType: String, Hashable, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case phrase = "Phrase"
    case address = "Address"
    case privateKey = "Private Key"
}

extension WalletImportType {
    public var title: String {
        switch self {
        case .phrase: Localized.Common.phrase
        case .privateKey: Localized.Common.privateKey
        case .address: Localized.Common.address
        }
    }

    public var description: String {
        switch self {
        case .phrase: Localized.Common.secretPhrase
        case .privateKey: Localized.Common.privateKey
        case .address: Localized.Common.address
        }
    }

    public var showToolbar: Bool {
        switch self {
        case .phrase: true
        case .privateKey, .address: false
        }
    }

    public var keyboardType: UIKeyboardType {
        switch self {
        case .phrase: .default
        case .privateKey, .address: .asciiCapable
        }
    }
}


extension WalletImportType: Equatable {
    public static func == (lhs: WalletImportType, rhs: WalletImportType) -> Bool {
        lhs.id == rhs.id
    }
}
