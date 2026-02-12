// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Foundation

struct CustomNodeULRFetchable: NodeURLFetchable {
    let url: URL
    let requestInterceptor: any RequestInterceptable

    init(url: URL, requestInterceptor: any RequestInterceptable = EmptyRequestInterceptor()) {
        self.url = url
        self.requestInterceptor = requestInterceptor
    }

    func node(for chain: Chain) -> URL { url }
}
