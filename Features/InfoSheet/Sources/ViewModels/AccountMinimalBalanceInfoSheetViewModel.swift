// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style
import Formatters
import BigInt

public struct AccountMinimalBalanceInfoSheetViewModel: InfoSheetModelViewable {
    
    private let asset: Asset
    private let required: BigInt
    public let button: InfoSheetButton?
    
    public init(asset: Asset, required: BigInt, button: InfoSheetButton?) {
        self.asset = asset
        self.required = required
        self.button = button
    }
    
    public var title: String {
        Localized.Info.AccountMinimumBalance.title
    }
    
    public var description: String {
        let amount = ValueFormatter(style: .full).string(required, asset: asset)
        return Localized.Transfer.minimumAccountBalance(amount)
    }
    
    public var image: InfoSheetImage? {
        .image(Images.Logo.logo)
    }
    
    public var buttonTitle: String {
        switch button {
        case .url, .none: Localized.Common.learnMore
        case .action(let title, _): title
        }
    }
}
