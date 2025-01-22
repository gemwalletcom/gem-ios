// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct TransferDataExtra: Equatable, Sendable {
    public let gasLimit: BigInt?
    public let gasPrice: GasPriceType?
    public let data: Data?
    
    public init(
        gasLimit: BigInt? = .none,
        gasPrice: GasPriceType? = .none,
        data: Data? = .none
    ) {
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.data = data
    }
}
extension TransferDataExtra: Hashable {}
