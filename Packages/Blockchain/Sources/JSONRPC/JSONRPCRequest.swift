// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

struct JSONRPCRequest<T: Encodable>: Encodable {
    let jsonrpc: String
    let method: String
    let params: T
    let id: Int
    
    init(method: String, params: T, id: Int) {
        self.jsonrpc = "2.0"
        self.method = method
        self.params = params
        self.id = id
    }
}
