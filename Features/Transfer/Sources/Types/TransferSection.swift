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
    public let items: [TransferListItem]

    public init(type: TransferSectionType, items: [TransferListItem]) {
        self.type = type
        self.items = items
    }

    public init(
        type: TransferSectionType,
        @ListItemBuilder<TransferListItem> items: () -> [TransferListItem]
    ) {
        self.type = type
        self.items = items()
    }

    public var id: String { type.id }
}

// MARK: - Section Convenience Methods

public extension TransferSection {
    static func main(
        @ListItemBuilder<TransferListItem> _ items: () -> [TransferListItem]
    ) -> Self {
        .init(type: .main, items: items())
    }
    
    static func fee(
        @ListItemBuilder<TransferListItem> _ items: () -> [TransferListItem]
    ) -> Self {
        .init(type: .fee, items: items())
    }
    
    static func error(
        @ListItemBuilder<TransferListItem> _ items: () -> [TransferListItem]
    ) -> Self {
        .init(type: .error, items: items())
    }
}

public enum TransferListItem: ListItemRepresentable, CommonListItemFactory {
    case common(CommonListItem)

    case memo(String)
    case address(viewModel: AddressListItemViewModel)
    case swapDetails(viewModel: SwapDetailsViewModel)
    case selectableFee(title: String, value: String?, fiat: String?, onSelect: VoidAction)
    
    public var id: String {
        switch self {
        case let .common(item): item.id
        case let .memo(text): "transfer-memo-\(text.hashValue)"
        case let .address(viewModel): "transfer-address-\(viewModel.account.address)"
        case .swapDetails: "transfer-swap-details"
        case let .selectableFee(title, value, fiat, _): "transfer-fee-selectable-\(title)-\((value ?? "").hashValue)"
        }
    }
}

// MARK: - Factory Methods

public extension TransferListItem {
    static func sender(_ title: String, name: String, image: AssetImage? = nil, menu: ContextMenuConfiguration? = nil) -> Self {
        .entity(title, name: name, image: image, contextMenu: menu)
    }
    
    static func network(_ title: String, name: String, image: AssetImage) -> Self {
        .entity(title, name: name, image: image)
    }
    
    static func fee(
        _ title: String,
        value: String? = nil,
        fiat: String? = nil,
        selectable: Bool = false,
        onSelect: VoidAction = nil,
        onInfo: VoidAction = nil
    ) -> Self {
        if selectable {
            .selectableFee(title: title, value: value, fiat: fiat, onSelect: onSelect)
        } else {
            .amount(title, value: value, fiat: fiat, infoAction: onInfo)
        }
    }
}
