// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum KeystoreImportType: Sendable {
    case phrase(secretData: SecretData, chains: [Chain])
    case single(secretData: SecretData, chain: Chain)
    case privateKey(secretData: SecretData, chain: Chain)
    case address(address: String, chain: Chain)

    public var walletType: WalletType {
        switch self {
        case .phrase: .multicoin
        case .single: .single   
        case .privateKey: .privateKey
        case .address: .view
        }
    }
}
