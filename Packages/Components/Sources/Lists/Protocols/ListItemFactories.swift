// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol CommonListItemFactory: ListItemRepresentable {
    static func common(_ item: CommonListItem) -> Self
}

public extension CommonListItemFactory {
    static func date(_ title: String, value: String) -> Self {
        .common(.date(title, value: value))
    }
    
    static func amount(_ title: String, value: String?, fiat: String? = nil, infoAction: (() -> Void)? = nil) -> Self {
        .common(.amount(title, value: value, fiat: fiat, infoAction: infoAction))
    }
    
    static func entity(_ title: String, name: String, image: AssetImage? = nil, contextMenu: ContextMenuConfiguration? = nil) -> Self {
        .common(.entity(title, name: name, image: image, contextMenu: contextMenu))
    }
    
    static func error(_ title: String, error: Error, action: (() -> Void)? = nil) -> Self {
        .common(.failure(title, error: error, retry: action))
    }
    
    static func loading() -> Self {
        .common(.loading)
    }
}
