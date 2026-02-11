// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol NodeURLFetchable: Sendable {
    func node(for chain: Chain) -> URL
    var requestInterceptor: any RequestInterceptable { get }
}

public extension NodeURLFetchable {
    var requestInterceptor: any RequestInterceptable { EmptyRequestInterceptor() }
}