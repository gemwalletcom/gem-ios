// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum SigningdExtra: Sendable {
    case vote([String: UInt64])
}

public struct TransactionData: Sendable {
    public let data: SigningData
    public let block: SignerInputBlock
    // Solana only
    public let token: SignerInputToken
    public var fee: Fee
    public let messageBytes: String
    public let extra: SigningdExtra?
    public let metadata: TransactionLoadMetadata

    public init(
        data: SigningData = .none,
        block: SignerInputBlock = SignerInputBlock(),
        token: SignerInputToken = SignerInputToken(),
        fee: Fee,
        messageBytes: String = "",
        extra: SigningdExtra? = nil,
        metadata: TransactionLoadMetadata = .none
    ) {
        self.data = data
        self.block = block
        self.token = token
        self.fee = fee
        self.messageBytes = messageBytes
        self.extra = extra
        self.metadata = metadata
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
