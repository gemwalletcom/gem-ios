// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension URL {
    public func cleanHost() -> String? {
         guard let host else { return host}
         let values = ["www."]
         for value in values {
             if host.hasPrefix(value) {
                 return host.replacingOccurrences(of: value, with: "")
             }
         }
         return host
     }
}
