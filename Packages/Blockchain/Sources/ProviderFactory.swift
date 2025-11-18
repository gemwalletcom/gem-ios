// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient

public struct ProviderFactory {
    public static func create<T: TargetType>(options: ProviderOptions) -> Provider<T> {
        return Provider<T>(options: options)
    }
    
    public static func create<T: TargetType>(with baseUrl: URL) -> Provider<T> {
        return Provider<T>(options: ProviderOptions(baseUrl: baseUrl))
    }
}

extension Chain {
    public var defaultBaseUrl: URL {
        return Constants.nodesURL.appending(component: self.rawValue.lowercased())
    }
    
    public var defaultNode: Node {
        return Node(url: defaultBaseUrl.absoluteString, status: .active, priority: 10)
    }
    
    public var defaultChainNode: ChainNode {
        return ChainNode(chain: rawValue, node: defaultNode)
    }

    public var europeChainNode: ChainNode {
        return ChainNode(
            chain: rawValue,
            node: Node(
                url: Constants.nodesEuropeURL.appending(component: self.rawValue.lowercased()).absoluteString,
                status: .active,
                priority: 9
            )
        )
    }
    
    public var asiaChainNode: ChainNode {
        return ChainNode(
            chain: rawValue,
            node: Node(
                url: Constants.nodesAsiaURL.appending(component: self.rawValue.lowercased()).absoluteString,
                status: .active,
                priority: 8
            )
        )
    }
}
