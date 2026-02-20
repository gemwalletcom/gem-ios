// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum RewardsSheetType: Identifiable, Sendable {
    case walletSelector
    case share
    case createCode
    case activateCode(code: String)
    case url(URL)

    public var id: String {
        switch self {
        case .walletSelector: "walletSelector"
        case .share: "share"
        case .createCode: "createCode"
        case .activateCode: "activateCode"
        case .url(let url): "url-\(url)"
        }
    }
}
