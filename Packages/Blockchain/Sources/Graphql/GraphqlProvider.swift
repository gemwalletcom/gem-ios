// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum GraphqlProvider: TargetType {
    
    case request(GraphqlRequest)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var method: HTTPMethod {
        .POST
    }
    
    public var path: String {
        ""
    }
    
    public var data: RequestData {
        switch self {
        case .request(let request): .encodable(request)
        }
    }
    
    public var contentType: String {
        ContentType.json.rawValue
    }
    
}
