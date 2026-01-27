// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum EarnType: String, Codable, CaseIterable, Equatable, Sendable {
    case stake
    case yield
}

public struct EarnPosition: Codable, Equatable, Hashable, Sendable {
    public let walletId: String
    public let assetId: AssetId
    public let type: EarnType
    public let balance: String
    public let rewards: String?
    public let apy: Double?

    // Stake-specific
    public let validatorId: String?
    public let state: DelegationState?
    public let completionDate: Date?
    public let delegationId: String?
    public let shares: String?

    // Yield-specific
    public let provider: String?
    public let name: String?
    public let vaultTokenAddress: String?
    public let assetTokenAddress: String?
    public let vaultBalanceValue: String?
    public let assetBalanceValue: String?

    public init(
        walletId: String,
        assetId: AssetId,
        type: EarnType,
        balance: String,
        rewards: String?,
        apy: Double?,
        validatorId: String? = nil,
        state: DelegationState? = nil,
        completionDate: Date? = nil,
        delegationId: String? = nil,
        shares: String? = nil,
        provider: String? = nil,
        name: String? = nil,
        vaultTokenAddress: String? = nil,
        assetTokenAddress: String? = nil,
        vaultBalanceValue: String? = nil,
        assetBalanceValue: String? = nil
    ) {
        self.walletId = walletId
        self.assetId = assetId
        self.type = type
        self.balance = balance
        self.rewards = rewards
        self.apy = apy
        self.validatorId = validatorId
        self.state = state
        self.completionDate = completionDate
        self.delegationId = delegationId
        self.shares = shares
        self.provider = provider
        self.name = name
        self.vaultTokenAddress = vaultTokenAddress
        self.assetTokenAddress = assetTokenAddress
        self.vaultBalanceValue = vaultBalanceValue
        self.assetBalanceValue = assetBalanceValue
    }
}
