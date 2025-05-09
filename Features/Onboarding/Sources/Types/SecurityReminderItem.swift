// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Style
import Components
import Localization

struct SecurityReminderItem: Identifiable {
    var id: String { [title,subtitle].joined() }

    let title: String
    let subtitle: String
    let image: ListItemImageStyle?
}

extension SecurityReminderItem {
    static let createWallet: [Self] = [
        SecurityReminderItem(
            title: Localized.Onboarding.Security.CreateWallet.KeepSafe.title,
            subtitle: Localized.Onboarding.Security.CreateWallet.KeepSafe.subtitle,
            image: .security(Emoji.WalletAvatar.lock.rawValue)
        ),
        SecurityReminderItem(
            title: Localized.Onboarding.Security.CreateWallet.DoNotShare.title,
            subtitle: Localized.Onboarding.Security.CreateWallet.DoNotShare.subtitle,
            image: .security(Emoji.WalletAvatar.warning.rawValue)
        ),
        SecurityReminderItem(
            title: Localized.Onboarding.Security.CreateWallet.NoRecovery.title,
            subtitle: Localized.Onboarding.Security.CreateWallet.NoRecovery.subtitle,
            image: .security(Emoji.WalletAvatar.gem.rawValue)
        )
    ]
}
