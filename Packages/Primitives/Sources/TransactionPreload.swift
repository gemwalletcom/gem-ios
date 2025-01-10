// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum SigningdExtra: Sendable {
    case vote([String: UInt64])
}

public struct TransactionPreload: Sendable {
    public let accountNumber: Int
    public let sequence: Int
    public let data: SigningData
    public let block: SignerInputBlock
    // Solana only
    public let token: SignerInputToken
    public let chainId: String
    public var fee: Fee
    public let utxos: [UTXO]
    public let messageBytes: String
    public let extra: SigningdExtra?

    public init(
        accountNumber: Int = 0,
        sequence: Int = 0,
        data: SigningData = .none,
        block: SignerInputBlock = SignerInputBlock(),
        token: SignerInputToken = SignerInputToken(),
        chainId: String = "",
        fee: Fee,
        utxos: [UTXO] = [],
        messageBytes: String = "",
        extra: SigningdExtra? = nil
    ) {
        self.accountNumber = accountNumber
        self.sequence = sequence
        self.data = data
        self.block = block
        self.token = token
        self.chainId = chainId
        self.fee = fee
        self.utxos = utxos
        self.messageBytes = messageBytes
        self.extra = extra
    }
}

// Solana only
public struct SignerInputToken: Sendable {
    public let senderTokenAddress: String
    public let recipientTokenAddress: String?
    public let tokenProgram: SolanaTokenProgramId

    public init(
        senderTokenAddress: String = "",
        recipientTokenAddress: String? = .none,
        tokenProgram: SolanaTokenProgramId = .token
    ) {
        self.senderTokenAddress = senderTokenAddress
        self.recipientTokenAddress = recipientTokenAddress
        self.tokenProgram = tokenProgram
    }
}
