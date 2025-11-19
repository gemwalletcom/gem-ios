// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives

@Suite
struct NetworkErrorTests {
    
    @Test
    func testNetworkErrors() throws {
        let networkErrorCodes: [Int] = [
            NSURLErrorNotConnectedToInternet,
            NSURLErrorCannotFindHost,
            NSURLErrorCannotConnectToHost,
            NSURLErrorNetworkConnectionLost
        ]
        
        for code in networkErrorCodes {
            let error = NSError(domain: NSURLErrorDomain, code: code)
            #expect(isNetworkError(error) == true)
        }
        
        let nonNetworkErrors: [(domain: String, code: Int)] = [
            ("OtherDomain", NSURLErrorNotConnectedToInternet)
        ]
        
        for (domain, code) in nonNetworkErrors {
            let error = NSError(domain: domain, code: code)
            #expect(isNetworkError(error) == false)
        }
    }
}
