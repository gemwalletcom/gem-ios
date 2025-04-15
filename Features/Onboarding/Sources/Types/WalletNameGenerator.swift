// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import ManageWalletService

struct WalletNameGenerator {
    private let type: ImportWalletType
    private let manageWalletService: ManageWalletService

    init(type: ImportWalletType, manageWalletService: ManageWalletService) {
        self.type = type
        self.manageWalletService = manageWalletService
    }

    var name: String {
        name(
            type: type,
            index: (try? manageWalletService.nextWalletIndex()) ?? .zero
        )
    }

    private func name(type: ImportWalletType, index: Int) -> String {
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
