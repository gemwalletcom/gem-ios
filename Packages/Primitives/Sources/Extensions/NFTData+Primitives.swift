// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension NFTData: Identifiable {
    public var id: String {
        collection.id
    }
}

extension NFTAsset {
    public func getContractAddress() throws -> String {
        guard let contractAddress else {
            throw AnyError("No contract address")
        }
        return contractAddress
    }
}
