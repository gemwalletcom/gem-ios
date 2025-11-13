// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization

enum WalletImportType: String, Hashable, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case phrase
    case address
    case privateKey
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
}


extension WalletImportType: Equatable {
    public static func == (lhs: WalletImportType, rhs: WalletImportType) -> Bool {
        lhs.id == rhs.id
    }
}
