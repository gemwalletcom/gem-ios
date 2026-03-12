// Copyright (c). Gem Wallet. All rights reserved.

import Style

public protocol ListItemViewDisplayable {
    var title: TextValue? { get }
    var titleExtra: TextValue? { get }
    var titleTag: TextValue? { get }
    var titleTagType: TitleTagType { get }
    var subtitle: TextValue? { get }
    var subtitleExtra: TextValue? { get }
    var imageStyle: ListItemImageStyle? { get }
}

public extension ListItemViewDisplayable {
    var title: TextValue? { nil }
    var titleExtra: TextValue? { nil }
    var titleTag: TextValue? { nil }
    var titleTagType: TitleTagType { .none }
    var subtitle: TextValue? { nil }
    var subtitleExtra: TextValue? { nil }
    var imageStyle: ListItemImageStyle? { nil }
}
