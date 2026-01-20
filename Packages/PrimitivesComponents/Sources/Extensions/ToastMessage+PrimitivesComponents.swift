// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Localization
import Style

public extension ToastMessage {
    static func copied(_ value: String) -> ToastMessage {
        ToastMessage(title: Localized.Common.copied(value), image: SystemImage.copy)
    }

    static func copy(_ message: String) -> ToastMessage {
        ToastMessage(title: message, image: SystemImage.copy)
    }

    static func pin(_ name: String, pinned: Bool) -> ToastMessage {
        ToastMessage(
            title: pinned ? "\(Localized.Common.pinned) \(name)" : "\(Localized.Common.unpin) \(name)",
            image: pinned ? SystemImage.pin : SystemImage.unpin
        )
    }

    static func addedToWallet() -> ToastMessage {
        ToastMessage(title: Localized.Asset.addToWallet, image: SystemImage.plusCircle)
    }

    static func showAsset(visible: Bool) -> ToastMessage {
        ToastMessage(
            title: visible ? Localized.Asset.addToWallet : Localized.Asset.hideFromWallet,
            image: visible ? SystemImage.plusCircle : SystemImage.minusCircle
        )
    }

    static func priceAlert(for assetName: String, enabled: Bool) -> ToastMessage {
        ToastMessage(
            title: enabled ? Localized.PriceAlerts.enabledFor(assetName) : Localized.PriceAlerts.disabledFor(assetName),
            image: SystemImage.bellFill
        )
    }

    static func priceAlert(message: String) -> ToastMessage {
        ToastMessage(title: message, image: SystemImage.bellFill)
    }

    static func success(_ message: String) -> ToastMessage {
        ToastMessage(title: message, image: SystemImage.checkmark)
    }

    static func error(_ message: String) -> ToastMessage {
        ToastMessage(title: message, image: SystemImage.xmarkCircle)
    }
}