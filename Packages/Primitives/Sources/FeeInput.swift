// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct FeeInput: Sendable {
    public let type: TransferDataType
    public let senderAddress: String
    public let destinationAddress: String
    public let value: BigInt
    public let balance: BigInt
    public let gasPrice: GasPriceType
    public let memo: String?

    public init(
        type: TransferDataType,
        senderAddress: String,
        destinationAddress: String,
        value: BigInt,
        balance: BigInt,
        gasPrice: GasPriceType,
        memo: String?
    ) {
        self.type = type
        self.senderAddress = senderAddress
        self.destinationAddress = destinationAddress
        self.value = value
        self.balance = balance
        self.gasPrice = gasPrice
        self.memo = memo
    }
    
    public var isMaxAmount: Bool {
        return balance > 0 && balance == value
    }
    
    public var chain: Chain {
        switch type {
        case .transfer(let asset):
            return asset.chain
        case .transferNft(let asset):
            return asset.chain
        case .swap(let fromAsset, _, _, _):
            // support multiple
            return fromAsset.chain
        case .generic(let asset, _, _):
            return asset.chain
        case .stake(let asset, _), .account(let asset, _):
            return asset.chain
        }
    }
}
