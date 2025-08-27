// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct TransferDataExtra: Equatable, Sendable {
    public enum OutputType: Equatable, Sendable {
        case encodedTransaction
        case signature
    }
    public let gasLimit: BigInt?
    public let gasPrice: GasPriceType?
    public let data: Data?
    public let decodedCall: DecodedCall?
    public let outputType: OutputType

    public init(
        gasLimit: BigInt? = .none,
        gasPrice: GasPriceType? = .none,
        data: Data? = .none,
        decodedCall: DecodedCall? = .none,
        outputType: OutputType = .encodedTransaction
    ) {
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.data = data
        self.decodedCall = decodedCall
        self.outputType = outputType
    }
}
extension TransferDataExtra: Hashable {}
