// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct BannerInfo: Codable, FetchableRecord {
    let banner: BannerRecord
    let asset: AssetRecord?
    let chain: AssetRecord?
    let wallet: WalletRecord?
    
    init(row: Row) throws {
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
