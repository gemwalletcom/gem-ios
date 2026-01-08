// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents

struct RecentAssetsSection: Identifiable {
    let date: Date
    let assets: [RecentAsset]

    var id: String { title }
    var title: String { TransactionDateFormatter(date: date).section }

    static func from(_ recentAssets: [RecentAsset]) -> [RecentAssetsSection] {
        Dictionary(grouping: recentAssets) { Calendar.current.startOfDay(for: $0.createdAt) }
            .map { RecentAssetsSection(date: $0.key, assets: $0.value) }
            .sorted { $0.date > $1.date }
    }
}
