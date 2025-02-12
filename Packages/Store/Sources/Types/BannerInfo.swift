// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct BannerInfo: Codable, FetchableRecord {
    public let banner: BannerRecord
    public let asset: AssetRecord?
    public let chain: AssetRecord?
    public let wallet: WalletRecord?
    
    public init(row: Row) throws {
        banner = try BannerRecord(row: row)
        asset = row["asset"]
        chain = row["chain"]
        wallet = row["wallet"]
    }
}

extension BannerInfo {
    func mapToBanner() -> Banner {
        Banner(
            wallet: wallet?.mapToWallet(),
            asset: asset?.mapToAsset(),
            chain: chain?.chain,
            event: banner.event,
            state: banner.state
        )
    }
}
