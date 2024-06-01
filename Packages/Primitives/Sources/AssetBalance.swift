import Foundation
import BigInt

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
