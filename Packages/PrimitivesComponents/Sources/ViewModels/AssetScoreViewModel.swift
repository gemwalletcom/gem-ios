// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import GemstonePrimitives
import Components
import Style

public enum AssetScoreViewModel {
    case verified
    case unverified
    case malicious

    public init(score: Int32) {
        switch score {
        case ...5:
            self = .malicious
        case 6...15:
            self = .unverified
        default:
            self = .verified
        }
    }
    
    public var hasWarning: Bool {
        switch self {
        case .malicious, .unverified: true
        case .verified: false
        }
    }
    
    public var status: String {
        switch self {
        case .verified: .empty
        case .unverified: Localized.Asset.Verification.unverified
        case .malicious: Localized.Asset.Verification.malicious
        }
    }
    
    public var assetImage: AssetImage? {
        switch self {
        case .verified: AssetImage()
        case .unverified: AssetImage(placeholder: Images.AssetVerification.orange)
        case .malicious: AssetImage(placeholder: Images.AssetVerification.red)
        }
    }

    public var docsUrl: URL {
        Docs.url(.tokenVerification)
    }
}
