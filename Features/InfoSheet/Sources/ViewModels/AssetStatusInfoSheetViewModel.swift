// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style

public struct AssetStatusInfoSheetViewModel: InfoSheetModelViewable {
    
    private let status: AssetScoreType
    
    public init(status: AssetScoreType) {
        self.status = status
    }
    
    public var title: String {
        switch status {
        case .verified: .empty
        case .suspicious: Localized.Asset.Verification.suspicious
        case .unverified: Localized.Asset.Verification.unverified
        }
    }
    
    public var description: String {
        switch status {
        case .verified: .empty
        case .unverified: Localized.Info.AssetStatus.Unverified.description
        case .suspicious: Localized.Info.AssetStatus.Suspicious.description
        }
    }
    
    public var image: InfoSheetImage? {
        switch status {
        case .verified: .image(Images.Logo.logo)
        case .unverified: .image(Images.TokenStatus.warning)
        case .suspicious: .image(Images.TokenStatus.risk)
        }
    }
    
    public var button: InfoSheetButton? {
        .url(Docs.url(.tokenVerification))
    }
    
    public var buttonTitle: String {
        Localized.Common.learnMore
    }
}