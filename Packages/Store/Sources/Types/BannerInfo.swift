// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct BannerInfo: Codable, FetchableRecord {
    public let banner: BannerRecord
    public let asset: AssetRecord?
}

extension BannerInfo {
    func mapToBanner() -> Banner {
        Banner(
            wallet: .none, //FIXME
            asset: asset?.mapToAsset(),
            event: banner.event,
            state: banner.state
        )
    }
}
