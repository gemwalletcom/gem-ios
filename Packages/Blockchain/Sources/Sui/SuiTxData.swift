// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct SuiTxData: Codable {
    public let txData: Data
    public let digest: Data

    public init(txData: Data, digest: Data) {
        self.txData = txData
        self.digest = digest
    }
    
    var data: String {
        txData.base64EncodedString() + "_" + digest.hexString
    }
}
