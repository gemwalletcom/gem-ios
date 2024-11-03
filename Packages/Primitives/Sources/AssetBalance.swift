import Foundation
import BigInt

public enum AssetBalanceType {
    case coin(balance: BigInt)
    case token(balance: BigInt)
    case stake(staked: BigInt, pending: BigInt, rewards: BigInt, reserved: BigInt, locked: BigInt, frozen: BigInt)
}

public struct AssetBalanceChange {
    public let assetId: AssetId
    public let type: AssetBalanceType
    
    public init(assetId: AssetId, type: AssetBalanceType) {
        self.assetId = assetId
        self.type = type
    }
}

public struct AssetBalance: Codable {
	public let assetId: AssetId
	public let balance: Balance

	public init(
        assetId: AssetId,
        balance: Balance
    ) {
		self.assetId = assetId
		self.balance = balance
	}
}

extension AssetBalance {
    public var coinChange: AssetBalanceChange {
        AssetBalanceChange(
            assetId: assetId,
            type: AssetBalanceType.coin(balance: balance.available)
        )
    }
    public var tokenChange: AssetBalanceChange {
        AssetBalanceChange(
            assetId: assetId,
            type: AssetBalanceType.token(
                balance: balance.available
            )
        )
    }

    public var stakeChange: AssetBalanceChange {
        AssetBalanceChange(
            assetId: assetId,
            type: AssetBalanceType.stake(
                staked: balance.staked,
                pending: balance.pending,
                rewards: balance.rewards,
                reserved: balance.reserved,
                locked: balance.locked,
                frozen: balance.frozen
            )
        )
    }
}

public struct WalletAssetBalance: Codable {
    public let walletId: String
    public let balance: AssetBalance

    public init(
        walletId: String,
        balance: AssetBalance
    ) {
        self.walletId = walletId
        self.balance = balance
    }
}

public extension AssetBalance {
    static func make(
        for assetId: AssetId,
        balance: Balance = Balance(available: .zero)
    ) -> AssetBalance {
        return AssetBalance(
            assetId: assetId,
            balance: balance
        )
    }
}
