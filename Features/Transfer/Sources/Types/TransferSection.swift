// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import PrimitivesComponents
import Swap

public enum TransferSectionType: String {
    case main
    case fee
    case error
    
    var id: String { "transfer-section-\(rawValue)" }
}

public struct TransferSection: ListSectionRepresentable {
    public let type: TransferSectionType
    public let items: [TransferItemContent]

    public init(type: TransferSectionType, items: [TransferItemContent]) {
        self.type = type
        self.items = items
    }

    public init(
        type: TransferSectionType,
        @ListItemBuilder<TransferItemContent> items: () -> [TransferItemContent]
    ) {
        self.type = type
        self.items = items()
    }

    public var id: String { type.id }
}

public enum TransferItemContent: ListItemRepresentable {
    case common(CommonListItem)

    case network(title: String, name: String, image: AssetImage)
    case fee(title: String, value: String? = nil, fiatValue: String? = nil, selectable: Bool = false)
    case address(viewModel: AddressListItemViewModel)
    case swapDetails(viewModel: SwapDetailsViewModel)
    
    public var id: String {
        switch self {
        case let .common(item): item.id
        case let .network(_, name, _): "transfer-network-\(name)"
        case let .fee(title, _, _, _): "transfer-fee-\(title)"
        case let .address(viewModel): "transfer-address-\(viewModel.account.address)"
        case .swapDetails: "transfer-swap-details"
        }
    }
}

// MARK: - Content Factory

public extension TransferItemContent {
    static func app(title: String, name: String, image: AssetImage?, contextMenu: ContextMenuConfiguration? = nil) -> Self {
        .common(.standard(title: title, subtitle: name, image: image, contextMenu: contextMenu))
    }
    
    static func wallet(title: String, name: String, image: AssetImage?, contextMenu: ContextMenuConfiguration? = nil) -> Self {
        .common(.standard(title: title, subtitle: name, image: image, contextMenu: contextMenu))
    }
    
    static func memo(text: String) -> Self {
        .common(.text(text))
    }
    
    static func error(title: String, error: Error, action: VoidAction) -> Self {
        .common(.error(title: title, error: error, action: action))
    }
}
