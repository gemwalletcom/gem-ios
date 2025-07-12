// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization

public enum AppDisplayFormatter {
    public static func format(name: String?, host: String?) -> String {
        let name = name?.trimmingCharacters(in: .whitespaces)
        let host = host?.trimmingCharacters(in: .whitespaces)
        
        if let name = name, !name.isEmpty {
            if let host = host, !host.isEmpty {
                return "\(name) (\(host))"
            }
            return name
        }
        
        if let host = host, !host.isEmpty {
            return host
        }
        
        return Localized.Errors.unknown
    }
}
