// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

enum RecentGroup: Comparable, Hashable {
    case today
    case earlier

    var title: String {
        switch self {
        case .today: Localized.Date.today
        case .earlier: Localized.Date.earlier
        }
    }

    static func from(_ date: Date) -> RecentGroup {
        Calendar.current.isDateInToday(date) ? .today : .earlier
    }
}

struct RecentAssetsSection: Identifiable {
    let group: RecentGroup
    let assets: [RecentAsset]

    var id: RecentGroup { group }

    var title: String { group.title }

    static func from(_ recentAssets: [RecentAsset]) -> [RecentAssetsSection] {
        Dictionary(grouping: recentAssets) { RecentGroup.from($0.createdAt) }
            .map { RecentAssetsSection(group: $0.key, assets: $0.value) }
            .sorted { $0.group < $1.group }
    }
}
