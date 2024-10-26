// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import Foundation

struct URLDecoderTest {

    @Test func testDecoderUrl() async throws {
        let decoder = URLDecoder()
        
        #expect(try decoder.decode("cloudflare-eth.com") == URL(string: "https://cloudflare-eth.com"))
        #expect(try decoder.decode("https://cloudflare-eth.com") == URL(string: "https://cloudflare-eth.com"))
        
        #expect(throws: URLDecoderError.unsupportedScheme) {
            try decoder.decode("http://cloudflare-eth.com")
        }
    }
}
