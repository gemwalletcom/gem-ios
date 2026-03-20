// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import PrimitivesComponents

public enum FiatTransactionDetailSectionType: String, Identifiable, Equatable {
    case details
    case explorer

    public var id: String { rawValue }
}

public enum FiatTransactionDetailItem: Identifiable, Equatable, Sendable {
    case status
    case provider
    case explorerLink

    public var id: Self { self }
}

public enum FiatTransactionDetailItemModel {
    case listItem(ListItemModel)
    case listImageItem(title: String, subtitle: String, image: AssetImage)
    case explorer(url: URL, text: String)
    case empty
}

extension FiatTransactionDetailItemModel: ItemModelProvidable {
    public var itemModel: FiatTransactionDetailItemModel { self }
}

public extension ListSection where T == FiatTransactionDetailItem {
    init(type: FiatTransactionDetailSectionType, _ items: [FiatTransactionDetailItem]) {
        self.init(type: type, values: items)
    }
}
