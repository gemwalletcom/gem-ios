// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import GemstonePrimitives
import Components
import Style

public struct AssetScoreViewModel {
    private let scoreType: AssetScoreType

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
    
    public var assetImage: AssetImage? {
        switch scoreType {
        case .verified: AssetImage()
        case .unverified: AssetImage(placeholder: Images.AssetVerification.orange)
        case .suspicious: AssetImage(placeholder: Images.AssetVerification.red)
        }
    }

    public var docsUrl: URL {
        Docs.url(.tokenVerification)
    }
}
