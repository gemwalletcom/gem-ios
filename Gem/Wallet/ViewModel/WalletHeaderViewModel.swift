// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Store
import Primitives
import BigInt
import Style
import Components
import GemstonePrimitives

struct WalletHeaderViewModel {
    //Remove WalletType from here
    let walletType: WalletType
    let value: Double
    
    let currencyFormatter = CurrencyFormatter.currency()
    
    public init(
        walletType: WalletType,
        value: Double
    ) {
        self.walletType = walletType
        self.value = value
    }
    
    public var totalValueText: String {
        return currencyFormatter.string(value)
    }
}

extension WalletHeaderViewModel: HeaderViewModel {
    
    var isWatchWallet: Bool {
        walletType == .view
    }
    
    var assetImage: AssetImage? {
        return .none
    }
    
    var title: String {
        return totalValueText
    }
    
    var subtitle: String? {
        return .none
    }
    
    var buttons: [HeaderButton] {
        let values: [(type: HeaderButtonType, isShown: Bool)] = [
            (.send, true),
            (.receive, true),
            (.buy, true),
        ]
        return values.compactMap {
            if $0.isShown {
                return HeaderButton(type: $0.type, isEnabled: true)
            }
            return .none
        }
    }
}
