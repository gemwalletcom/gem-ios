// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import GemstonePrimitives
import Components
import Style

public struct AssetScoreViewModel {
    public let scoreType: AssetScoreType

    public init(score: Int32) {
        switch score {
        case ...5: scoreType = .suspicious
        case 6...15: scoreType = .unverified
        default: scoreType = .verified
        }
    }
    
    public var hasWarning: Bool {
        switch scoreType {
        case .suspicious, .unverified: true
        case .verified: false
        }
    }
    
    public var status: String {
        switch scoreType {
        case .verified: .empty
        case .unverified: Localized.Asset.Verification.unverified
        case .suspicious: Localized.Asset.Verification.suspicious
        }
    }
    
    public var statusStyle: TextStyle {
        switch scoreType {
        case .verified: .calloutSecondary
        case .unverified: TextStyle(font: .callout, color: Colors.orange)
        case .suspicious: TextStyle(font: .callout, color: Colors.red)
        }
    }
    
    public var assetImage: AssetImage {
        switch scoreType {
        case .verified: AssetImage(placeholder: Images.TokenStatus.verified)
        case .unverified: AssetImage(placeholder: Images.TokenStatus.warning)
        case .suspicious: AssetImage(placeholder: Images.TokenStatus.risk)
        }
    }

    public var docsUrl: URL {
        Docs.url(.tokenVerification)
    }
}
