// Copyright (c). Gem Wallet. All rights reserved.

public struct PaymentLinkData: Sendable, Hashable {
    public let label: String
    public let logo: String
    public let chain: Chain
    public let transaction: String

    public init(
        label: String,
        logo: String,
        chain: Chain,
        transaction: String
    ) {
        self.label = label
        self.logo = logo
        self.chain = chain
        self.transaction = transaction
    }
}
