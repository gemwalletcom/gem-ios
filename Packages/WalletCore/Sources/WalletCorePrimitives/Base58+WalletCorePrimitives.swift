// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Primitives

extension Base58 {
    public static func decodeNoCheck(string: String) throws -> Data {
        guard let data = Base58.decodeNoCheck(string: string) else {
            throw AnyError("Invalid base64 string")
        }
        return data
    }
    
    public static func decode(string: String) throws -> Data {
        guard let data = Base58.decode(string: string) else {
            throw AnyError("Invalid base64 string")
        }
        return data
    }
}
