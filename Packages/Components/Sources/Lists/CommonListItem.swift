// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum CommonListItem: ListItemRepresentable {
    case detail(title: String, subtitle: String, image: AssetImage? = nil, contextMenu: ContextMenuConfiguration? = nil)
    case value(label: String, value: String?, extra: String? = nil, infoAction: (() -> Void)? = nil)
    case error(title: String, error: Error, action: (() -> Void)? = nil)
    case loading
    
    public var id: String {
        switch self {
        case let .detail(title, subtitle, _, _): "common-detail-\(title.hashValue)-\(subtitle.hashValue)"
        case let .value(label, value, extra, _): "common-value-\(label)-\((value ?? "").hashValue)-\((extra ?? "").hashValue)"
        case let .error(title, error, _): "common-error-\(title)-\(String(describing: error).hashValue)"
        case .loading: "common-loading"
        }
    }
    
    public var contextMenu: ContextMenuConfiguration? {
        switch self {
        case let .detail(_, _, _, contextMenu): contextMenu
        default: nil
        }
    }
}

// MARK: - Factory Methods

public extension CommonListItem {
    // Entity items (wallet, app, network, provider, etc.)
    static func entity(
        _ title: String,
        name: String,
        image: AssetImage? = nil,
        contextMenu: ContextMenuConfiguration? = nil
    ) -> Self {
        .detail(title: title, subtitle: name, image: image, contextMenu: contextMenu)
    }
    
    // Date/time items
    static func date(_ title: String, value: String) -> Self {
        .detail(title: title, subtitle: value)
    }
    
    // Monetary values (fee, amount, price)
    static func amount(
        _ title: String,
        value: String?,
        fiat: String? = nil,
        infoAction: (() -> Void)? = nil
    ) -> Self {
        .value(label: title, value: value, extra: fiat, infoAction: infoAction)
    }
    
    // Error
    static func failure(
        _ title: String,
        error: Error,
        retry: (() -> Void)? = nil
    ) -> Self {
        .error(title: title, error: error, action: retry)
    }
    
    // Loading
    static func progress() -> Self {
        .loading
    }
}
