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
        return URL(string: "https://gemnodes.com/\(self.rawValue.lowercased())")!
    }
    
    public var defaultNode: Node {
        return Node(url: defaultBaseUrl.absoluteString, status: .active, priority: 10)
    }
    
    public var defaultChainNode: ChainNode {
        return ChainNode(chain: self.rawValue, node: defaultNode)
    }
    
    public var asiaChainNode: ChainNode {
        return ChainNode(
            chain: rawValue,
            node: Node(url: URL(string: "https://asia.gemnodes.com/\(self.rawValue.lowercased())")!.absoluteString, status: .active, priority: 10)
        )
    }
}
