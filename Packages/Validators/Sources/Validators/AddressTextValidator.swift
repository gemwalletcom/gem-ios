// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

internal import WalletCorePrimitives

public struct AddressTextValidator: TextValidator {
    private let asset: Asset

    public init(asset: Asset) {
        self.asset = asset
    }

    public func validate(_ text: String) throws {
        guard asset.chain.isValidAddress(text) else {
            throw TransferError.invalidAddress(asset: asset)
        }
    }

    public var id: String { asset.id.identifier }
}

public extension TextValidator where Self == AddressTextValidator {
    static func address(_ asset: Asset) -> Self {
        .init(asset: asset)
    }
}
