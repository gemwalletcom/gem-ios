// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct BannerInfo: Codable, FetchableRecord {
    public let banner: BannerRecord
    public let asset: AssetRecord?
    public let wallet: WalletRecord?
}

extension BannerInfo {
    func mapToBanner() -> Banner {
        Banner(
            wallet: wallet?.mapToWallet(),
            asset: asset?.mapToAsset(),
            event: banner.event,
            state: banner.state
        )
    }
}
