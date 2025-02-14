// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import BigInt
import Style
import Components
import GemstonePrimitives
import PrimitivesComponents
import AvatarToolkit

public struct WalletHeaderViewModel {
    //Remove WalletType from here
    let walletType: WalletType
    let value: Double
    
    let currencyFormatter: CurrencyFormatter

    public init(
        walletType: WalletType,
        value: Double,
        currencyCode: String
    ) {
        self.walletType = walletType
        self.value = value
        self.currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: currencyCode)
    }
    
    public var totalValueText: String {
        currencyFormatter.string(value)
    }
}

// MARK: - HeaderViewModel

extension WalletHeaderViewModel: HeaderViewModel {
    public var allowHiddenBalance: Bool { true }
    public var isWatchWallet: Bool { walletType == .view }
    public var title: String { totalValueText }
    public var assetImage: AssetImage? { .none }
    public var subtitle: String? { .none }

    public var buttons: [HeaderButton] {
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
