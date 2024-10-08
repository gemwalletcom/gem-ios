// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Primitives

@MainActor
struct WalletNameGenerator {
    
    let type: ImportWalletType
    let keystore: any Keystore
    
    var name: String {
        let index = (try? keystore.getNextWalletIndex()) ?? 0
        return name(type: type, index: index)
    }
    
    func name(type: ImportWalletType, index: Int) -> String {
        switch type {
        case .multicoin: Localized.Wallet.defaultName(index)
        case .chain(let chain): Localized.Wallet.defaultNameChain(Asset(chain).name, index)
        }
    }
}

extension ImportWalletType {
    var type: WalletType {
        switch self {
        case .multicoin: .multicoin
        case .chain: .single
        }
    }
}
