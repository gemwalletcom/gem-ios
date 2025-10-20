// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct TransferDataExtra: Equatable, Sendable {
    public let to: String
    public let gasLimit: BigInt?
    public let gasPrice: GasPriceType?
    public let data: Data?
    public let outputType: TransferDataOutputType
    public let outputAction: TransferDataOutputAction

    public init(
        to: String,
        gasLimit: BigInt? = .none,
        gasPrice: GasPriceType? = .none,
        data: Data? = .none,
        outputType: TransferDataOutputType = .encodedTransaction,
        outputAction: TransferDataOutputAction = .send
    ) {
        self.to = to
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.data = data
        self.outputType = outputType
        self.outputAction = outputAction
    }
}
extension TransferDataExtra: Hashable {}
