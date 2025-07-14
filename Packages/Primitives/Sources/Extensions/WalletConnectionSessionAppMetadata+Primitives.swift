// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension WalletConnectionSessionAppMetadata {
    private static let separators = ["-", ":", "|"]
    
    public var shortName: String {
        let name = name.trimmingCharacters(in: .whitespaces)
        
        for separator in Self.separators {
            if let range = name.range(of: separator) {
                return String(name[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
        }
        
        if name.count > 80 {
            let endIndex = name.index(name.startIndex, offsetBy: 80)
            return String(name[..<endIndex])
        }
        
        return name
    }
}
