// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum BitcoinProvider: TargetType {

    public var baseUrl: URL {
        return URL(string: "")!
    }
    public var path: String { "" }
    public var method: HTTPMethod { return .GET }
    public var data: RequestData { .plain }
}
