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
            title: Localized.Onboarding.Security.CreateWallet.Item1.title,
            subtitle: Localized.Onboarding.Security.CreateWallet.Item1.subtitle,
            image: .security(Images.System.exclamationmarkTriangle)
        ),
        SecurityReminderItem(
            title: Localized.Onboarding.Security.CreateWallet.Item2.title,
            subtitle: Localized.Onboarding.Security.CreateWallet.Item2.subtitle,
            image: .security(Images.System.pencilLine)
        ),
        SecurityReminderItem(
            title: Localized.Onboarding.Security.CreateWallet.Item3.title,
            subtitle: Localized.Onboarding.Security.CreateWallet.Item3.subtitle,
            image: .security(Images.Logo.icon)
        )
    ]
}
