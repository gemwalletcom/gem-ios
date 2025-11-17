// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import enum Gemstone.WalletConnectResponseType
import ReownWalletKit

extension WalletConnectResponseType {
    func map() -> AnyCodable {
        switch self {
        case .string(let value):
            return AnyCodable(value)
        case .object(let json):
            guard let obj = try? JSONSerialization.jsonObject(with: json.encodedData()) else {
                return AnyCodable(json)
            }
            return AnyCodable(any: obj)
        }
    }
}
