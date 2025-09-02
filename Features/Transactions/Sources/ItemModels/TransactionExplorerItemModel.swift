// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct TransactionExplorerItemModel {
    public let url: URL
    public let text: String
    
    public init(url: URL, text: String) {
        self.url = url
        self.text = text
    }
}
