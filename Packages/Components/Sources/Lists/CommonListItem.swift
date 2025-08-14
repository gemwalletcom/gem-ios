// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum CommonListItem: ListItemRepresentable {
    case standard(title: String, subtitle: String, image: AssetImage? = nil, contextMenu: ContextMenuConfiguration? = nil)
    case error(title: String, error: Error, action: (()-> Void)?)
    case text(String)
    
    public var id: String {
        switch self {
        case let .standard(title, subtitle, _, _): "item-standard-\(title)-\(subtitle)"
        case let .error(title, _, _): "item-error-\(title)"
        case let .text(text): "item-text-\(text.hashValue)"
        }
    }
}
