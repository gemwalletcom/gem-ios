// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct StakePositionData: Codable, Equatable, Hashable, Sendable {
    public let validatorId: String
    public let state: DelegationState
    public let completionDate: Date?
    public let delegationId: String
    public let shares: String

    public init(
        validatorId: String,
        state: DelegationState,
        completionDate: Date?,
        delegationId: String,
        shares: String
    ) {
        self.validatorId = validatorId
        self.state = state
        self.completionDate = completionDate
        self.delegationId = delegationId
        self.shares = shares
    }
}

public struct YieldPositionData: Codable, Equatable, Hashable, Sendable {
    public let provider: String
    public let name: String
    public let vaultTokenAddress: String?
    public let assetTokenAddress: String?
    public let vaultBalanceValue: String?
    public let assetBalanceValue: String?

    public init(
        provider: String,
        name: String,
        vaultTokenAddress: String?,
        assetTokenAddress: String?,
        vaultBalanceValue: String?,
        assetBalanceValue: String?
    ) {
        self.provider = provider
        self.name = name
        self.vaultTokenAddress = vaultTokenAddress
        self.assetTokenAddress = assetTokenAddress
        self.vaultBalanceValue = vaultBalanceValue
        self.assetBalanceValue = assetBalanceValue
    }
}

public enum EarnType: Codable, Equatable, Hashable, Sendable {
    case stake(StakePositionData)
    case yield(YieldPositionData)

    public var isStake: Bool {
        if case .stake = self { return true }
        return false
    }

    public var isYield: Bool {
        if case .yield = self { return true }
        return false
    }

    public var stakeData: StakePositionData? {
        if case .stake(let data) = self { return data }
        return nil
    }

    public var yieldData: YieldPositionData? {
        if case .yield(let data) = self { return data }
        return nil
    }

    public var rawValue: String {
        switch self {
        case .stake: "stake"
        case .yield: "yield"
        }
    }
}

public struct EarnPosition: Codable, Equatable, Hashable, Sendable {
    public let walletId: String
    public let assetId: AssetId
    public let type: EarnType
    public let balance: String
    public let rewards: String?
    public let apy: Double?

    public init(
        walletId: String,
        assetId: AssetId,
        type: EarnType,
        balance: String,
        rewards: String?,
        apy: Double?
    ) {
        self.walletId = walletId
        self.assetId = assetId
        self.type = type
        self.balance = balance
        self.rewards = rewards
        self.apy = apy
    }
}
