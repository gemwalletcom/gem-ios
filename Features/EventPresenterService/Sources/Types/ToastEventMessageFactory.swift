// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Components
import Localization

public enum ToastEventMessageFactory {
    public static func makeToastMessage(for event: ToastEvent) -> ToastMessage? {
        switch event {
        case .transfer(let data): transferMessage(for: data.type)
        }
    }
}

// MARK: - Private

extension ToastEventMessageFactory {
    private static func transferMessage(for type: TransferDataType) -> ToastMessage? {
        guard case .perpetual(_, let perpetualType) = type else {
            return nil
        }
        return switch perpetualType {
        case .open(let data): .success(Localized.Perpetual.openDirection(PerpetualDirectionViewModel(direction: data.direction).title))
        case .close: .success(Localized.Perpetual.closePosition)
        case .modify: .success(Localized.Perpetual.modifyPosition)
        case .increase: .success(Localized.Perpetual.increasePosition)
        case .reduce: .success(Localized.Perpetual.reducePosition)
        }
    }
}
