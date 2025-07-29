// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style

public struct StakeLockTimeInfoSheetViewModel: InfoSheetModelViewable {
    
    private let placeholder: Image?
    
    public init(placeholder: Image?) {
        self.placeholder = placeholder
    }
    
    public var title: String {
        Localized.Stake.lockTime
    }
    
    public var description: String {
        Localized.Info.LockTime.description
    }
    
    public var image: InfoSheetImage? {
        .assetImage(AssetImage(
            imageURL: .none,
            placeholder: placeholder,
            chainPlaceholder: .none
        ))
    }
    
    public var button: InfoSheetButton? {
        .url(Docs.url(.stakingLockTime))
    }
    
    public var buttonTitle: String {
        Localized.Common.learnMore
    }
}