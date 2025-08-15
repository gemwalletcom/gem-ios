// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import PrimitivesComponents
import Style

public enum TransactionSectionType: String {
    case swapAction
    case details
    case explorer
    
    var id: String { "transaction-section-\(rawValue)" }
}

public struct TransactionSection: ListSectionRepresentable {
    public let type: TransactionSectionType
    public let items: [TransactionListItem]
    
    public init(type: TransactionSectionType, items: [TransactionListItem]) {
        self.type = type
        self.items = items
    }
    
    public init(
        type: TransactionSectionType,
        @ListItemBuilder<TransactionListItem> items: () -> [TransactionListItem]
    ) {
        self.type = type
        self.items = items()
    }
    
    public var id: String { type.id }
}

// MARK: - Section Convenience Methods

public extension TransactionSection {
    static func swapAction(
        @ListItemBuilder<TransactionListItem> _ items: () -> [TransactionListItem]
    ) -> Self { 
        .init(type: .swapAction, items: items()) 
    }

    static func details(
        @ListItemBuilder<TransactionListItem> _ items: () -> [TransactionListItem]
    ) -> Self { 
        .init(type: .details, items: items()) 
    }

    static func explorer(
        @ListItemBuilder<TransactionListItem> _ items: () -> [TransactionListItem]
    ) -> Self { 
        .init(type: .explorer, items: items()) 
    }
}

public enum TransactionListItem: ListItemRepresentable, CommonListItemFactory {
    case common(CommonListItem)

    case memo(String)
    case status(title: String, value: String, style: TextStyle, showProgressView: Bool, infoAction: VoidAction)
    case address(viewModel: AddressListItemViewModel)
    case explorerLink(text: String, url: URL)
    case swapButton(text: String, action: VoidAction)
    
    public var id: String {
        switch self {
        case let .common(item): item.id
        case let .memo(text): "transaction-memo-\(text.hashValue)"
        case let .status(title, value, _, _, _): "transaction-status-\(title)-\(value.hashValue)"
        case let .address(viewModel): "transaction-address-\(viewModel.account.address)"
        case let .explorerLink(text, url): "transaction-explorer-\(text)-\(url.absoluteString.hashValue)"
        case let .swapButton(text, _): "transaction-swap-button-\(text)"
        }
    }
}

// MARK: - Factory Methods

public extension TransactionListItem {
    static func fee(_ title: String, value: String, fiat: String? = nil, info: VoidAction = nil) -> Self {
        .amount(title, value: value, fiat: fiat, infoAction: info)
    }
    
    static func network(_ title: String, name: String, image: AssetImage) -> Self {
        .entity(title, name: name, image: image)
    }
    
    static func provider(_ title: String, name: String, image: AssetImage? = nil) -> Self {
        .entity(title, name: name, image: image)
    }
}
