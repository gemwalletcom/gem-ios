// Copyright (c). Gem Wallet. All rights reserved.

import ChainService
import Foundation
import Primitives

class MockURLProtocol: URLProtocol {
    public nonisolated(unsafe) static var error: Error?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = MockURLProtocol.error {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

struct MockNodeURL: NodeURLFetchable {
    let url: URL

    func node(for chain: Chain) -> URL {
        self.url
    }
}
