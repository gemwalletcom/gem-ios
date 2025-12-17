// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Localization
import Primitives
import Style

public struct ToastMessageViewModel {
    private let type: ToastType

    public init(type: ToastType) {
        self.type = type
    }

    public var toastMessage: ToastMessage {
        switch type {
        case .perpetualAutoclose: .success(Localized.Perpetual.autoClose)
        case .perpetualClose: .success(Localized.Perpetual.closePosition)
        case .perpetualOrder(let positionAction):
            switch positionAction {
            case .open(let data): .success(Localized.Perpetual.openDirection(PerpetualDirectionViewModel(direction: data.direction).title))
            case .increase: .success(Localized.Perpetual.increasePosition)
            case .reduce: .success(Localized.Perpetual.reducePosition)
            }
        }
    }
}
