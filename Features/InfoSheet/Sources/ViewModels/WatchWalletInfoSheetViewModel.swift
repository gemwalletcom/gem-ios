// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style

public struct WatchWalletInfoSheetViewModel: InfoSheetModelViewable {
    
    public init() {}
    
    public var title: String {
        Localized.Info.WatchWallet.title
    }
    
    public var description: String {
        Localized.Info.WatchWallet.description
    }
    
    public var image: InfoSheetImage? {
        .assetImage(
            AssetImage(
                imageURL: .none,
                placeholder: Images.Logo.logo,
                chainPlaceholder: Images.Wallets.watch
            )
        )
    }
    
    public var button: InfoSheetButton? {
        .url(Docs.url(.whatIsWatchWallet))
    }
    
    public var buttonTitle: String {
        Localized.Common.learnMore
    }
}