// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct ProviderOptions: Sendable {
    public let baseUrl: URL?
    
    public init(baseUrl: URL?) {
        self.baseUrl = baseUrl
    }
    
    public static let defaultOptions = ProviderOptions(baseUrl: .none)
}
