// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import BigInt
import Style
import Components
import Formatters

public struct WalletHeaderViewModel {
    //Remove WalletType from here
    let walletType: WalletType
    let value: Double
    let bannerEventsViewModel: HeaderBannerEventViewModel
    
    let currencyFormatter: CurrencyFormatter

    public init(
        walletType: WalletType,
        value: Double,
        currencyCode: String,
        bannerEventsViewModel: HeaderBannerEventViewModel
    ) {
        self.walletType = walletType
        self.value = value
        self.bannerEventsViewModel = bannerEventsViewModel
        self.currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: currencyCode)
    }
    
    public var totalValueText: String {
        currencyFormatter.string(value)
    }
}

// MARK: - HeaderViewModel

extension WalletHeaderViewModel: HeaderViewModel {
    public var isWatchWallet: Bool { walletType == .view }
    public var title: String { totalValueText }
    public var assetImage: AssetImage? { .none }
    public var subtitle: String? { .none }

    public var buttons: [HeaderButton] {
        [
            HeaderButton(type: .send, isEnabled: bannerEventsViewModel.isButtonsEnabled),
            HeaderButton(type: .receive, isEnabled: bannerEventsViewModel.isButtonsEnabled),
            HeaderButton(type: .buy, isEnabled: bannerEventsViewModel.isButtonsEnabled)
        ]
    }
}
