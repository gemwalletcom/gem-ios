// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension Bundle {
    public var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    public var buildVersionNumber: Int {
        return Int((infoDictionary?["CFBundleVersion"] as? String ?? "")) ?? 0
    }
}
