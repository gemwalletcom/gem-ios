// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum WalletImportType: String, Hashable, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case phrase = "Phrase"
    case address = "Address"
    case privateKey = "Private Key"

    var field: ImportWalletScene.Field {
        switch self {
        case .phrase: .phrase
        case .address: .address
        case .privateKey: .privateKey
        }
    }
}

extension WalletImportType {
    public var title: String {
        switch self {
        case .phrase:
            Localized.Common.phrase
        case .privateKey:
            Localized.Common.privateKey
        case .address:
            Localized.Common.address
        }
    }
}


extension WalletImportType: Equatable {
    public static func == (lhs: WalletImportType, rhs: WalletImportType) -> Bool {
        lhs.id == rhs.id
    }
}
