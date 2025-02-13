// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct TargetRequestBuilder {
    
    let baseUrl: URL
    let method: HTTPMethod
    let path: String
    let data: RequestData
    let contentType: String
    let cachePolicy: URLRequest.CachePolicy
    
    func build() -> URLRequest {
        let string: String
        var httpBody: Data? = .none
        switch data {
        case .params(let params):
            if method == .GET {
                let query = params.enumerated().map({ "\($1.key)=\($1.value)" }).joined(separator: "&")
                string = "\(path)?\(query)"
            } else {
                httpBody = Data(params.enumerated().map({ "\($1.key)=\($1.value)" }).joined(separator: "&").utf8)
                string = path
            }
        case .data(let data):
            httpBody = data
            string = path
        case .plain:
            string = path
        case .encodable(let value):
            httpBody = try! JSONEncoder().encode(value)
            string = path
        }
        let url = URL(string: baseUrl.absoluteString + string)!
        var request = URLRequest(url: url)
        request.httpBody = httpBody
        request.httpMethod = method.rawValue
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.cachePolicy = cachePolicy
        return request
    }
}
