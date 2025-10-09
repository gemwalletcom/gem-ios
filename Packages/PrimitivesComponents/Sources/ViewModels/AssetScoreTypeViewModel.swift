// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import GemstonePrimitives
import Components
import Style

public struct AssetScoreTypeViewModel {
    public let scoreType: AssetScoreType

    public init(score: Int32) {
        switch score {
        case ...5: scoreType = .suspicious
        case 6...15: scoreType = .unverified
        default: scoreType = .verified
        }
    }
    
    public init (scoreType: AssetScoreType) {
        self.scoreType = scoreType
    }
    
    public var hasWarning: Bool {
        switch scoreType {
        case .unverified: true
        case .verified, .suspicious: false
        }
    }
    
    public var shouldShowBanner: Bool {
        switch scoreType {
        case .verified, .unverified: false
        case .suspicious: true
        }
    }
    
    public var status: String {
        switch scoreType {
        case .verified: .empty
        case .unverified: Localized.Asset.Verification.unverified
        case .suspicious: Localized.Asset.Verification.suspicious
        }
    }
    
    public var description: String {
        switch scoreType {
        case .verified: String.empty
        case .unverified: Localized.Info.AssetStatus.Unverified.description
        case .suspicious: Localized.Info.AssetStatus.Suspicious.description
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
        case .verified: AssetImage()
        case .unverified: AssetImage(placeholder: Images.TokenStatus.warning)
        case .suspicious: AssetImage(placeholder: Images.TokenStatus.risk)
        }
    }

    public var docsUrl: URL {
        Docs.url(.tokenVerification)
    }
}
