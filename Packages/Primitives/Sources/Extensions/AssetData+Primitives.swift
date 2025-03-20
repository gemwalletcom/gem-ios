import Foundation
import BigInt

extension AssetData: Identifiable {
    public var id: String { asset.id.identifier }
}

public extension AssetData {
    var assetAddress: AssetAddress {
        AssetAddress(asset: asset, address: account.address)
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
        price_alerts.first(where: { $0.type == .auto }) != nil
    }
}
