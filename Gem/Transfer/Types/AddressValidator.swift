// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Keystore
import PrimitivesComponents

struct AddressValidator: TextValidator {
    private let asset: Asset

    init(asset: Asset) {
        self.asset = asset
    }

    func validate(_ text: String) throws {
        guard asset.chain.isValidAddress(text) else {
            throw TransferError.invalidAddress(asset: asset)
        }
    }
}

extension AddressValidator {
    var id: String {
        asset.id.identifier
    }
}
