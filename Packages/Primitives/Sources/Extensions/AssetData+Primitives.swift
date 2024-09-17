import Foundation
import BigInt

extension AssetData: Identifiable {
    public var id: String { asset.id.identifier }
}

public extension AssetData {
    var assetAddress: AssetAddress {
        return AssetAddress(asset: asset, address: account.address)
    }
    
    var balances: [BalanceType: BigInt] {
        return [
            BalanceType.available: balance.available,
            BalanceType.frozen: balance.frozen,
            BalanceType.locked: balance.locked,
            BalanceType.pending: balance.pending,
            BalanceType.staked: balance.staked,
            BalanceType.rewards: balance.rewards,
            BalanceType.reserved: balance.reserved,
        ]
    }

    var isPriceAlertsEnabled: Bool {
        price_alert != nil
    }
}

extension AssetData: Hashable {
    public static func == (lhs: AssetData, rhs: AssetData) -> Bool {
        return lhs.asset == rhs.asset
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(asset)
    }
}
