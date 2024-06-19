// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct SignerInput {
    public let type: TransferDataType
    public let asset: Asset
    public let value: BigInt
    public let fee: Fee
    public let useMaxAmount: Bool
    public let chainId: String
    public let memo: String?
    public let accountNumber: Int
    public let sequence: Int
    public let senderAddress: String
    public let destinationAddress: String
    public let block: SignerInputBlock
    // token: Solana only
    public let token: SignerInputToken
    public let utxos: [UTXO]
    public let messageBytes: String
    public let extra: SigningdExtra?

    public init(
        type: TransferDataType,
        asset: Asset,
        value: BigInt,
        fee: Fee,
        isMaxAmount: Bool,
        chainId: String,
        memo: String?,
        accountNumber: Int,
        sequence: Int,
        senderAddress: String,
        destinationAddress: String,
        block: SignerInputBlock,
        token: SignerInputToken,
        utxos: [UTXO],
        messageBytes: String,
        extra: SigningdExtra? = nil
    ) {
        self.type = type
        self.asset = asset
        self.value = value
        self.fee = fee
        self.useMaxAmount = isMaxAmount
        self.chainId = chainId
        self.memo = memo
        self.accountNumber = accountNumber
        self.sequence = sequence
        self.senderAddress = senderAddress
        self.destinationAddress = destinationAddress
        self.block = block
        self.token = token
        self.utxos = utxos
        self.messageBytes = messageBytes
        self.extra = extra
    }
}
