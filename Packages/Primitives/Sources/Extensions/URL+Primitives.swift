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
    
    public func appending(queryItems newItems: [URLQueryItem]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        var queryItems = components.queryItems ?? []
        queryItems.append(contentsOf: newItems)
        components.queryItems = queryItems
        return components.url!
    }
    
    public func withUTM(source: String) -> URL {
        return appending(queryItems: [URLQueryItem(name: "utm_source", value: source)])
    }

    public func queryValue(for name: String) -> String? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == name }?
            .value
    }

    public func queryValue<T: LosslessStringConvertible>(for name: String) -> T? {
        queryValue(for: name).flatMap { T($0) }
    }
}
