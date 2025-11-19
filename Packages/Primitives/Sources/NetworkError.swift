// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public func isNetworkError(_ error: Error) -> Bool {
    let nsError = error as NSError
    guard nsError.domain == NSURLErrorDomain else { return false }
    
    switch nsError.code {
    case NSURLErrorNotConnectedToInternet,
        NSURLErrorCannotFindHost,
        NSURLErrorCannotConnectToHost,
        NSURLErrorNetworkConnectionLost,
        NSURLErrorDNSLookupFailed,
        NSURLErrorBadURL:
        return true
    default:
        return false
    }
}

