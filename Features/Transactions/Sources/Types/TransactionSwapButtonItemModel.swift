// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct TransactionSwapButtonItemModel {
    public let text: String
    public let url: URL?
    
    public init(text: String, url: URL?) {
        self.text = text
        self.url = url
    }
}
